import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
actor {
    public type Message = {
        time:Time.Time;
        text:Text;
    };

    public type Microblog = actor {
        //添加关注对象
        follow: shared(Principal) -> async ();
        //返回关注列表
        follows: shared query () -> async [Principal];
        //发布新消息
        post: shared (Text) -> async ();
        //返回所有发布消息
        posts: shared query (Time.Time) -> async [Message];
        //发挥所有关注对象发布的消息
        timeline: shared (Time.Time) -> async [Message];
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal): async() {
        followed := List.push(id,followed);
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    stable var messages : List.List<Message> = List.nil();

    public shared(msg) func post(text : Text) : async(){
        assert(Principal.toText(msg.caller) == "ln3f5-oxw63-h3z2j-6df2p-qwa6p-mfghf-3ss7u-xhk4t-ktcjg-avh27-wqe");
        let time : Time.Time = Time.now();
        messages := List.push({time=time;text=text;},messages);
    };

    

    public shared query func posts(since : Time.Time) : async [Message]{
        var recent : List.List<Message> = List.nil();

        for(message in Iter.fromList(messages)){
            if(message.time > since ){
                recent := List.push(message,recent);
            }
        };
        List.toArray(recent)
    };

    

    public shared func timeline(since : Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)){
            let canister : Microblog= actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)){
                all := List.push(msg,all);                
            }
        };

        List.toArray(all)
    };


}