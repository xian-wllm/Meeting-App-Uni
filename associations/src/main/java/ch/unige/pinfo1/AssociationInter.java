package ch.unige.pinfo1;

import java.util.Set;



public interface AssociationInter{
    
    Set<Association> getAllAssociations();

    Association getAssociationsById(Integer id);

    Association getAssociationsByName(String id);

    Set<Association> getAssociationsByTag(Tags tag);
    
    void addAssociation(Association association);

    void editAssociation(Integer id, Association association);
    
    void deleteAssociation(Integer idToDelete);

}