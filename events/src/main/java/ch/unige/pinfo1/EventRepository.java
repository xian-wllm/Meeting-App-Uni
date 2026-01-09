package ch.unige.pinfo1;



import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EventRepository implements PanacheRepositoryBase<Event, Integer> {

}