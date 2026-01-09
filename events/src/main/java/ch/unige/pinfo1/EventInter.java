package ch.unige.pinfo1;

import java.util.Set;

public interface EventInter {

    Set<Event> getAllEvents();

    void addEvent(Event event);

    Set<Event> getEventByTag(Set<Tags> tag);

    Set<Event> getEventByAsso(Integer idAsso);

    Set<Event> getEventByParticipant(String idParticipant);

    Event getEventById(Integer id);

    void updateEvent(Integer id, Event event);

    void inscribeToEvent(Integer id);

    void deleteEvent(Integer id);

    Set<Event> getInterestingEvents(Integer findXEvt, Set<Tags> tag);


}
