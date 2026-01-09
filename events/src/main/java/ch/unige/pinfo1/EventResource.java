package ch.unige.pinfo1;

import jakarta.annotation.security.RolesAllowed;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import java.util.stream.Collectors;



import io.quarkus.oidc.UserInfo;
import io.quarkus.security.Authenticated;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;

import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;



@Path("/event")
@Transactional
@ApplicationScoped
public class EventResource implements EventInter {

    @Inject
    EventRepository repository;

    @Inject
    UserInfo userInfo;

    @GET
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    public Set<Event> getAllEvents() {
        Map<String, Object> params = new HashMap<>();
        return repository.find("SELECT e FROM Event e JOIN FETCH e.organisateurs JOIN FETCH e.participants JOIN FETCH e.tags", params).stream().collect(Collectors.toSet());
    }

    @POST
    @RolesAllowed({"Organisateur","ModoAssociations"})
    @Override
    public void addEvent(Event event) {
        repository.persist(event);
    }


    @POST
    @Authenticated
    @Override
    @Path("/findByTags")
    @SuppressWarnings("unchecked")
    public Set<Event> getEventByTag(Set<Tags> tag) {
        Set<Integer> ids = new HashSet<Integer>();
        for (Tags t : tag){
            Map<String, Object> params = new HashMap<>();
            params.put("tag", t);
            ids.addAll((Set<Integer>) (Object) repository.find("SELECT e.event_id FROM Event e JOIN e.tags t WHERE t = :tag", params).stream().collect(Collectors.toSet()));
        
        }
        
        Set<Event> setOut = outputSet(ids);
        return setOut;
    }

    @GET
    @Authenticated
    @Override
    @Path("/findByAsso/{id}")
    @SuppressWarnings("unchecked")
    public Set<Event> getEventByAsso(@PathParam("id") Integer id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        Set<Integer> ids = (Set<Integer>) (Object) repository.find("SELECT e.event_id FROM Event e JOIN e.organisateurs o WHERE o = :id", params).stream().collect(Collectors.toSet());
        
        Set<Event> setOut = outputSet(ids);
        return setOut;
    }

    @GET
    @Authenticated
    @Override
    @Path("/findByParticipant/{id}")
    @SuppressWarnings("unchecked")
    public Set<Event> getEventByParticipant(@PathParam("id") String id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        Set<Integer> ids = (Set<Integer>) (Object) repository.find("SELECT e.event_id FROM Event e JOIN e.participants p WHERE p = :id", params).stream().collect(Collectors.toSet());
        
        Set<Event> setOut = outputSet(ids);
        return setOut;
    }

    @GET
    @Authenticated
    @Override
    @Path("/{id}")
    public Event getEventById(@PathParam("id") Integer id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return repository.find("SELECT e FROM Event e JOIN FETCH e.organisateurs JOIN FETCH e.participants JOIN FETCH e.tags where e.event_id = :id", params).firstResult();
    }


    @PUT
    @RolesAllowed({"Organisateur","ModoAssociations"})
    @Override
    @Path("/{id}")
    public void updateEvent(@PathParam("id") Integer id, Event event) {
        Event editableEvent = repository.findById(id);
        editableEvent.setNom_event((event.getNom_event()));
        editableEvent.setDate(event.getDate());
        editableEvent.setDescription(event.getDescription());
        editableEvent.setTags(event.getTags());
        editableEvent.setParticipants(event.getParticipants());
        editableEvent.setOrganisateurs(event.getOrganisateurs());
        editableEvent.setIsPrivate(event.getIsPrivate());
        repository.persist(editableEvent);

    }


    @PUT
    @Authenticated
    @Override
    @Path("/Inscribe/{id}")
    public void inscribeToEvent(@PathParam("id") Integer id) {
        Event editableEvent = repository.findById(id);
        Set<String> part = editableEvent.getParticipants();
        part.add(userInfo.getSubject());
        editableEvent.setParticipants(part);
        repository.persist(editableEvent);
    }


    @DELETE
    @RolesAllowed({"Organisateur","ModoAssociations"})
    @Override
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/{id}")
    public void deleteEvent(@PathParam("id") Integer idToDelete) {
        repository.deleteById(idToDelete);
    }

    private Set<Event> outputSet(Set<Integer> ids) {
        Set<Event> setOut = new HashSet<Event>();
        for (Integer itId : ids) {
            Event event = getEventById(itId);
            if (event != null) {
                setOut.add(event);
            }
        }
        return setOut;
    }

    @POST
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    @Path("/Interesting/{nb}")
    public Set<Event> getInterestingEvents(@PathParam("nb") Integer findXEvt, Set<Tags> tag) {
        Set<Event> allTag = getEventByTag(tag);
        if (allTag.isEmpty()){
            return Collections.emptySet();
        } 

        List<Event> futureEvents = allTag.stream()
                .filter(event -> event.getDate().isAfter(LocalDateTime.now()))
                .collect(Collectors.toList());
        
        if (futureEvents.size()<= findXEvt){
            return new HashSet<>(futureEvents);
        } else {
            List<Event> sortedEvents = futureEvents.stream()
                    .sorted()
                    .collect(Collectors.toList());
            
            List<Event> closestEvents = sortedEvents.subList(0, findXEvt);
            return new HashSet<>(closestEvents);
        }
    }

}
