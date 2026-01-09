package ch.unige.pinfo1;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.HashSet;
import java.util.Set;



import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "association")
@Getter
@Setter
@NoArgsConstructor
public class Association {
    
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "asso_id")
    public Integer asso_id;

    @Column(name = "name")
    public String name;

    @Column(name = "description")
    public String description;

    @Column(name = "image")
    public String image;

    @Column(name = "canJoin")
    public Boolean canJoin;

    @ElementCollection
    @Column(name = "tags")
    public Set<Tags> tags;

    @ElementCollection
    @Column(name = "moderators")
    public Set<String> moderators;

    public Association(String name, String description, String image, Boolean canJoin, Set<String> mod, Set<Tags> tags){
        this.asso_id = null;
        this.name = name;
        this.description = description;
        this.canJoin = canJoin;
        this.image = image;
        this.moderators = new HashSet<>(mod);
        this.tags = new HashSet<>(tags);
    }
    
}
