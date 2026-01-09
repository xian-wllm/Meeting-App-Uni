package ch.unige.pinfo1;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AssociationRepository implements PanacheRepositoryBase<Association, Integer> {
    //

}