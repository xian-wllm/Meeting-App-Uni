package ch.unige.pinfo1;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "messagerie")
@Getter
@Setter
@NoArgsConstructor
public class Messagerie {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "messagerie_id")
    public Integer messagerie_id;
    
    @Column(name = "type")
    public Boolean type;

    @Column(name = "isPublic")
    public Boolean isPublic;

    @Column(name = "total_participants")
    public Integer total_participants;

    @ElementCollection
    @Column(name = "participants")
    public Set<String> participants; // IDs

    @ElementCollection
    @Column(name = "messages")
    public Set<Integer> messages; // IDs
    
    public Messagerie(Boolean type, Boolean isPublic, Integer total_participants, 
    Set<String> participants){
    this.messagerie_id = null;
    this.type = type;
    this.isPublic = isPublic;
    this.total_participants = total_participants;
    this.participants = new HashSet<>(participants);
    this.messages = new HashSet<>();
}

    
}
