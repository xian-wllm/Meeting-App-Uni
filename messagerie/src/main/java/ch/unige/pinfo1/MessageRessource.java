package ch.unige.pinfo1;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
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
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.MediaType;


@Path("/message")
@Transactional
@ApplicationScoped
public class MessageRessource {

    @Inject
    MessagerieRessource messagerieRessource;

    @Inject
    MessageRepository repositoryMess;

    @Inject
    MessagerieRepository repositoryMessagerie;

    @Inject
    UserInfo userInfo;

    @GET
    @Authenticated
    public Set<Message> getAllMessages() {
        return repositoryMess.findAll().stream().collect(Collectors.toSet());
        
    }

    @GET
    @Authenticated
    @Path("/{id}")
    public Message getMessageById(@PathParam("id") Integer id) {
        return repositoryMess.findById(id);
        
    }

    @GET
    @Authenticated
    @Path("/messagerie/{id}")
    public Set<Message> getMessagesByMessagerieId(@PathParam("id") Integer id) {
        Messagerie messagerie = messagerieRessource.getMessagerieById(id);
        if (!messagerie.getParticipants().contains(userInfo.getSubject())){
            throw new ForbiddenException("Vous ne participez pas à cette messagerie");
        }
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        Set<Message> messagesSet = repositoryMess.find("SELECT m FROM Message m where m.messagerie_id = :id", params).stream().collect(Collectors.toSet());
        List<Message> messagesSorted = messagesSet.stream().sorted().collect(Collectors.toList());
        return new LinkedHashSet<>(messagesSorted);
        
        
    }

    @POST
    @Authenticated
    @Path("/{id}")
    public void createNewMessage(@PathParam("id") Integer id, Message message) {

        Messagerie messagerie = repositoryMessagerie.findById(id);
        Set<Integer> messIds = messagerie.getMessages();
        message.setMessagerie_id(id);
        message.setSender_id(userInfo.getSubject());
        message.setHoraire(LocalDateTime.now());
        repositoryMess.persist(message);
        repositoryMess.flush();
        messIds.add(message.getMessage_id());
        messagerie.setMessages(messIds);
        
    }

    @DELETE
    @Authenticated
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/{messagerieId}/{id}")
    public void deleteMessage(@PathParam("messagerieId") Integer messagerieId, @PathParam("id") Integer idToDelete) {

        Messagerie editableMessagerie = repositoryMessagerie.findById(messagerieId);
        Set<Integer> messages = editableMessagerie.getMessages();
        messages.remove(idToDelete);
        editableMessagerie.setMessages(messages);
        repositoryMessagerie.persist(editableMessagerie);

        repositoryMess.deleteById(idToDelete);

    }
}
