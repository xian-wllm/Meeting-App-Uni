package ch.unige.pinfo1;

import java.util.Set;

public interface UserInter {
    
    Set<Utilisateur> getAllUsers();

    void addUser(Utilisateur user);

    Utilisateur getUserByName(String username);

    Utilisateur getUserById(String id);

    void deleteUser(String id);

    void updateProfile(String id, Utilisateur user);

}
