package ch.unige.pinfo1;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;

import java.util.List;
import java.util.Map;
import java.util.Set;

import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import io.quarkus.oidc.UserInfo;
import io.quarkus.security.Authenticated;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.transaction.Transactional.TxType;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;

import jakarta.ws.rs.POST;

import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/match")
@Transactional
@ApplicationScoped
public class MatchesRessource{

    @Inject
	@Channel("messagerieMatch")
	Emitter<String> messagerieEmitter;

    @Inject
    MatchesRepository matchesRepository;

    @Inject
    UserRessource userRessource;

    @Inject
    UserInfo userInfo;



    @GET
    @Authenticated
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Set<Matches> getAllOfUser(@PathParam("id") String id) {
        Map<String, Object> params = new HashMap<>();
        params.put("user_id", id);
        return matchesRepository.find("SELECT m FROM Matches m WHERE user_id = :user_id", params).stream().collect(Collectors.toSet());
        }

    @POST
    @Authenticated
    @Path("acceptMatch/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Set<String> acceptMatchWithId(@PathParam("id") String id) {
        Set<Matches> matchesOfMatch = getAllOfUser(id);
        Matches alreadyMatch = new Matches(id, userInfo.getSubject(), true);
        Matches match = new Matches(userInfo.getSubject(), id, true);
        matchesRepository.persist(match);
        
        if(matchesOfMatch.contains(alreadyMatch)){
            sendKafka(id);
            return Set.of(userInfo.getSubject(), id);
        } else {
            
            return Collections.emptySet(); 
        }
        
    }

    @POST
    @Authenticated
    @Path("refuseMatch/{id}")
    public void refuseMatchWithId(@PathParam("id") String id) {
        Matches match = new Matches(userInfo.getSubject(), id, false);
        matchesRepository.persist(match);
    }

    @GET
    @Authenticated
    @Path("potentialMatches/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Set<String> getPotentialMatches(@PathParam("id") String id) {
        Set<Matches> potentialMatches = getAllMatches();

        List<Matches> unvalidMatches = potentialMatches.stream()
            .filter(match -> match.getMatched_id().equals(id) && !match.getAccepted() || match.getUser_id().equals(id)).toList();

        List<String> invalidIds = unvalidMatches.stream()
            .flatMap(match -> Stream.of(match.getMatched_id(), match.getUser_id())).toList();

        Set<String> invalidIdsSet = new HashSet<>(invalidIds);

        Set<Utilisateur> allUsers = userRessource.getAllUsers();
        Utilisateur self = userRessource.getUserById(id);

        List<Utilisateur> validUsers = allUsers.stream()
            .filter(match -> self.getInterests().contains(match.getGender())).toList();
        
        List<String> restOfId = validUsers.stream()
            .flatMap(match -> Stream.of(match.getId())).toList();

        Set<String> validMatches = new HashSet<>(restOfId);
        
        validMatches.removeAll(invalidIdsSet);
        validMatches.remove(self.getId());

        return new HashSet<>(validMatches);
        }


    @GET
    @Authenticated
    @Path("getAllMatches")
    public Set<Matches> getAllMatches(){
        return matchesRepository.findAll().stream().collect(Collectors.toSet());
    }

    @DELETE
    @Authenticated
    @Path("delAllMatches")
    public void delAllMatches(){
        matchesRepository.deleteAll();
    }

    @Transactional(TxType.REQUIRES_NEW)
    public void sendKafka(String id){
        messagerieEmitter.send(userInfo.getSubject()+"££"+id).toCompletableFuture().join();
    }

}