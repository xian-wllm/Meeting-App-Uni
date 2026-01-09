package ch.unige.pinfo1;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "message")
@Getter
@Setter
@NoArgsConstructor
public class Message implements Comparable<Message>{
    
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "message_id")
    public Integer message_id;

    @Column(name = "messagerie_id")
    public Integer messagerie_id;

    @Column(name = "content")
    public String content;

    @Column(name = "sender_id")
    public String sender_id;

    @Column(name = "horaire")
    public LocalDateTime horaire;

    public Message(String content){
        this.message_id = null;
        this.content = content;
    }

    public int compareTo(Message mess) {
        return horaire.compareTo(mess.horaire);
    }
}
