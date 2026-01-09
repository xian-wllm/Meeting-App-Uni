package ch.unige.pinfo1;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Entity
@Table(name = "utilisateur")
@Getter
@Setter
@NoArgsConstructor
public class Utilisateur {

    @Id
    @Column(name = "user_id")
    public String id;

    @Column(name = "name")
    public String fullname;

    @Column(name = "date_naissance")
    public LocalDateTime dateOfBirth;

    @Column(name = "email")
    public String email;

    @ElementCollection
    @Column(name = "bloque_liste")
    public Set<String> blockedUsers;

    // Contenu de "Profil" donc pas nécessaire à initialiser
    @Column(name = "match")
    public Boolean match;

    @Column(name = "description")
    public String description;

    @Column(name = "faculte")
    public Faculte faculte;

    @Column(name = "sexe")
    public Gender gender;

    @Column(name = "couleur")
    public Color couleur;

    @Column(name = "photo")
    public String profilePic;

    @ElementCollection
    @Column(name = "liste_photo")
    public Set<String> liste_photo;

    @ElementCollection
    @Column(name = "interesse_par")
    public Set<Gender> interests;
    //public Set<User> matchs;

    @ElementCollection
    @Column(name = "interets")
    public Set<centerOfInterest> centersOfInterest;

public Utilisateur(String id, String fullname, LocalDateTime dateOfBirth, String email, Set<String> blockedUsers){
    this.id = id;
    this.fullname = fullname;
    this.dateOfBirth = dateOfBirth;
    this.email = email;
    this.blockedUsers = blockedUsers;

    this.match = false;
    this.description = null;
    this.faculte = null;
    this.gender = null;
    this.couleur = Color.Rose;
    this.profilePic = null;
    this.liste_photo = new HashSet<String>();
    this.interests = new HashSet<Gender>();
    this.centersOfInterest = new HashSet<centerOfInterest>();

}

public Utilisateur(String id, String fullname, LocalDateTime dateOfBirth, String email, Set<String> blockedUsers, Boolean match, Color couleur, String profilePic, Set<String> liste_photo, Faculte faculte, Gender gender, Set<Gender> interests, String biographie, Set<centerOfInterest> centersOfInterest){
    this.id = id;
    this.fullname = fullname;
    this.dateOfBirth = dateOfBirth;
    this.email = email;
    this.blockedUsers = blockedUsers;

    this.match = match;
    this.couleur = couleur;
    this.profilePic = profilePic;
    this.liste_photo = liste_photo;
    this.faculte = faculte;
    this.gender = gender;
    this.interests = interests;
    this.description = biographie;
    this.centersOfInterest = centersOfInterest;
}
    
}
