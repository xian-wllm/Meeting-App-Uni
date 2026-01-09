package ch.unige.pinfo1;

import java.util.HashMap;

import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import io.quarkus.oidc.UserInfo;
import io.quarkus.security.Authenticated;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/utilisateur")
@Transactional
@ApplicationScoped
public class UserRessource implements UserInter{

    @Inject
    UserRepository userRepo;

    UserInfo userInfo;

    @GET
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    public Set<Utilisateur> getAllUsers() {
        Map<String, Object> params = new HashMap<>();
        return userRepo.find("SELECT u FROM Utilisateur u LEFT JOIN FETCH u.blockedUsers LEFT JOIN FETCH u.liste_photo LEFT JOIN FETCH u.interests LEFT JOIN FETCH u.centersOfInterest", params).stream().collect(Collectors.toSet());
        }

    @POST
    @Authenticated
    @Override
    public void addUser(Utilisateur user) {
        userRepo.persist(user);
    }

    @GET
    @Authenticated
    @Override
    @Path("/getName/{name}")
    public Utilisateur getUserByName(@PathParam("name") String username) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", username);
        return userRepo.find("SELECT u FROM Utilisateur u LEFT JOIN FETCH u.blockedUsers LEFT JOIN FETCH u.liste_photo LEFT JOIN FETCH u.interests LEFT JOIN FETCH u.centersOfInterest WHERE u.fullname = :name", params).firstResult();
             
    }

    @GET
    @Authenticated
    @Override
    @Path("/{id}")
    public Utilisateur getUserById(@PathParam("id") String id) {
        Map<String, Object> params = new HashMap<>();
        params.put("user_id", id);
        return userRepo.find("SELECT u FROM Utilisateur u LEFT JOIN FETCH u.blockedUsers LEFT JOIN FETCH u.liste_photo LEFT JOIN FETCH u.interests LEFT JOIN FETCH u.centersOfInterest WHERE u.id = :user_id", params).firstResult();
    }

    @PUT
    @Authenticated
    @Override
    @Path("/profile/{id}")
    public void updateProfile(@PathParam("id") String id, Utilisateur user) {
        Utilisateur editableUser = userRepo.findById(id);
        if (editableUser != null) {
            editableUser.setFullname(Optional.ofNullable(user.getFullname()).orElse(editableUser.getFullname()));
            editableUser.setMatch(Optional.ofNullable(user.getMatch()).orElse(editableUser.getMatch()));
            editableUser.setDescription(Optional.ofNullable(user.getDescription()).orElse(editableUser.getDescription()));
            editableUser.setFaculte(Optional.ofNullable(user.getFaculte()).orElse(editableUser.getFaculte()));
            editableUser.setGender(Optional.ofNullable(user.getGender()).orElse(editableUser.getGender()));
            editableUser.setCouleur(Optional.ofNullable(user.getCouleur()).orElse(editableUser.getCouleur()));
            editableUser.setBlockedUsers(Optional.ofNullable(user.getBlockedUsers()).orElse(editableUser.getBlockedUsers()));
            editableUser.setProfilePic(Optional.ofNullable(user.getProfilePic()).orElse(editableUser.getProfilePic()));
            editableUser.setListe_photo(Optional.ofNullable(user.getListe_photo()).orElse(editableUser.getListe_photo()));
            editableUser.setInterests(Optional.ofNullable(user.getInterests()).orElse(editableUser.getInterests()));
            editableUser.setCentersOfInterest(Optional.ofNullable(user.getCentersOfInterest()).orElse(editableUser.getCentersOfInterest()));

            userRepo.persist(editableUser);
        } else { throw new NotFoundException();}
    }

    @DELETE
    @Authenticated
    @Override
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/{id}")
    public void deleteUser(@PathParam("id") String idToDelete) {
        userRepo.delete("id", idToDelete);
    }
}