package ch.unige.pinfo1;

import jakarta.annotation.security.RolesAllowed;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;


import java.util.HashMap;
import java.util.HashSet;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import io.quarkus.oidc.UserInfo;
import io.quarkus.security.Authenticated;
import jakarta.inject.Inject;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/association")
@Transactional
@ApplicationScoped
public class AssociationResource implements AssociationInter{

    @Inject
    AssociationRepository repository;

    @Inject
    UserInfo userInfo;

    @GET
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    public Set<Association> getAllAssociations() {
        Map<String, Object> params = new HashMap<>();
        return repository.find("SELECT a FROM Association a JOIN FETCH a.moderators JOIN FETCH a.tags", params).stream().collect(Collectors.toSet());
    }

    @GET
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    @Path("/findById/{id}")
    public Association getAssociationsById(@PathParam("id") Integer id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return repository.find("SELECT a FROM Association a JOIN FETCH a.moderators JOIN FETCH a.tags where a.asso_id = :id", params).firstResult();
    }

    @GET
    @Authenticated
    @Produces(MediaType.APPLICATION_JSON)
    @Override
    @Path("/findByName/{name}")
    public Association getAssociationsByName(@PathParam("name") String name) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        return repository.find("SELECT a FROM Association a JOIN FETCH a.moderators JOIN FETCH a.tags where a.name = :name", params).firstResult();
    }

    @GET
    @Authenticated
    @Override
    @Path("/findByTags/{tag}")
    @SuppressWarnings("unchecked")
    public Set<Association> getAssociationsByTag(@PathParam("tag") Tags tag) {
        Map<String, Object> params = new HashMap<>();
        params.put("tag", tag);
        Set<Integer> ids = (Set<Integer>) (Object) repository.find("SELECT a.asso_id FROM Association a JOIN a.tags t where t = :tag", params).stream().collect(Collectors.toSet());
        
        Set<Association> setOut = new HashSet<Association>();
        for (Integer itId : ids) {
            Association asso = getAssociationsById(itId);
            if (asso != null) {
                setOut.add(asso);
            }
        }
        return setOut;
    }


    @POST
    @Override
    @RolesAllowed("AdminAssociations")
    public void addAssociation(Association association) {
        repository.persist(association);
    }

    @PUT
    @Override
    @Path("/{id}")
    @RolesAllowed("ModoAssociations")
    public void editAssociation(@PathParam("id") Integer id, Association updatedAsso) {
        Association assoToEdit = repository.findById(id);
        if (!assoToEdit.getModerators().contains(userInfo.getSubject())){
            throw new ForbiddenException("Votre role de modérateur ne correspond pas à cette association");
        }
        assoToEdit.setName(updatedAsso.getName());
        assoToEdit.setImage(updatedAsso.getImage());
        assoToEdit.setDescription(updatedAsso.getDescription());
        assoToEdit.setCanJoin(updatedAsso.getCanJoin());
        assoToEdit.setModerators(updatedAsso.getModerators());
        repository.persist(assoToEdit);
    }

    @DELETE
    @Override
    @Path("/{id}")
    @RolesAllowed("AdminAssociations")
    public void deleteAssociation(@PathParam("id") Integer idToDelete) {
        repository.deleteById(idToDelete);
    }
}
