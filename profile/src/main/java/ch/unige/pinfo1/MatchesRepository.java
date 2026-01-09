package ch.unige.pinfo1;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class MatchesRepository implements PanacheRepositoryBase<Matches, String> {
    //
}
