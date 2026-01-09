package ch.unige.pinfo1;

import java.util.HashMap;
import java.util.HashSet;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import io.quarkus.security.Authenticated;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;

import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;

import jakarta.ws.rs.core.MediaType;

@Path("/messagerie")
@Transactional
@ApplicationScoped
public class MessagerieRessource {

    @Inject
    MessagerieRepository repositoryMessagerie;

    @Inject
    MessageRepository repositoryMessage;

    @GET
    @Authenticated
    @Path("/{id}")
    public Messagerie getMessagerieById(@PathParam("id") Integer id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return repositoryMessagerie.find("SELECT m FROM Messagerie m LEFT JOIN FETCH m.participants LEFT JOIN FETCH m.messages where m.messagerie_id = :id", params).firstResult();
        
    }

    @POST
    @Authenticated
    public void createNewMessagerie(Messagerie messagerie) {
        repositoryMessagerie.persist(messagerie);
    }

    @GET
    @Authenticated
    @Path("/user/{idUser}")
    @SuppressWarnings("unchecked")
    public Set<Messagerie> getMessagerieByUser(@PathParam("idUser") String idUser) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", idUser);
        Set<Integer> ids = (Set<Integer>) (Object) repositoryMessagerie.find("SELECT m.messagerie_id FROM Messagerie m JOIN m.participants p WHERE p = :id", params).stream().collect(Collectors.toSet());
        
        Set<Messagerie> setOut = new HashSet<Messagerie>();
        for (Integer itId : ids) {
            Messagerie event = getMessagerieById(itId);
            if (event != null) {
                setOut.add(event);
            }
        }
        return setOut;
        
    }

    @PUT
    @Authenticated
    @Path("/{id}")
    public void updateMessagerie(@PathParam("id") Integer id, Messagerie messagerie) {
        Messagerie editableMessagerie = repositoryMessagerie.findById(id);
        editableMessagerie.setType((messagerie.getType()));
        editableMessagerie.setIsPublic(messagerie.getIsPublic());
        editableMessagerie.setTotal_participants(messagerie.getTotal_participants());
        editableMessagerie.setParticipants(messagerie.getParticipants());
        repositoryMessagerie.persist(editableMessagerie);

    }

    @DELETE
    @Authenticated
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/{id}")
    public void deleteMessagerie(@PathParam("id") Integer idToDelete) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", idToDelete);

        repositoryMessagerie.deleteById(idToDelete);
        repositoryMessage.delete("messagerie_id", idToDelete);
    }


}
