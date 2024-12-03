import Text "mo:base/Text";
import Nat32 "mo:base/Nat8";
import Trie "mo:base/Trie";
import List "mo:base/List";
import Principal "mo:base/Principal";
//budget tracker application
actor Budget {
    //data model
    //each user has many periods which have many expenses each
    public type Expense = {
        date : Text;
        details : Text;
        amount : Nat32;
    };

    public type Period = {
        start : Nat32;
        end : Nat32;
        expenses : List.List<Expense>; //store expenses in a linked list
    };

    public type User = {
        periods: List.List<Period>;
    };

    //user data store
    private stable var users : Trie.Trie <Principal, User> = Trie.empty();
};
