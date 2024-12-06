import Text "mo:base/Text";
import Nat32 "mo:base/Nat8";
import Trie "mo:base/Trie";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import Option "mo:base/Option";
//budget tracker application
actor Budget {

    type Key<K> = Trie.Key<K>;

    func key(p : Principal) : Key<Principal> {
        { hash = Principal.hash p; key = p };
    };

    //data model
    //each user has many periods which have many expenses each
    public type Expense = {
        date : Nat32;// unix timestamp
        category : Text;
        details : Text;
        amount : Nat32;
    };

    public type Period = {
        start : Nat32;
        end : Nat32;
        budget: Nat32;
        expenses : List.List<Expense>; //store expenses in a linked list
    };

    //user has many spending periods of expenses
    public type User = {
        periods : List.List<Period>;
    };

    //stores users
    private stable var users : Trie.Trie<Principal, User> = Trie.empty();

    //add new user
    public func addUser(userId : Principal, user : User) : async Principal {
        users := Trie.put(
            users,
            key userId,
            Principal.equal,
            user,
        ).0;
        return userId;
    };

    // add expense to user in a given period
    // categorization of expenses is not implemented
    public func newExpense(userId : Principal, expense : Expense) : async Bool {
        //find user
        let user = Trie.find(users, key(userId), Principal.equal);
        let exists = Option.isSome(user);
        //if they exist find which period the expense will be
        //get periods
        if (exists) {

            switch (user) {
                case (null) {
                    return false;
                };
                case (?user) {
                    let periods = user.periods;
                    //iterate over the periods
                    for (p in List.toIter<Period>(periods)) {
                        //find the period the expense belongs to
                        if (p.start <= expense.date and p.end >= expense.date) {
                            //create new expense list with the new expense
                            let updatedExpenses = List.push(expense, p.expenses);
                            //create new period with updated expenses
                            let updatedPeriod = {
                                start = p.start;
                                end = p.end;
                                budget = p.budget;
                                expenses = updatedExpenses;
                            };

                            //update the user with the new period
                            // !! Needs review !!
                            //this iterates over each peraod and updates the one that matches the expense date, otherwise it returns the original period
                            let updatedPeriods = List.map<Period, Period>(
                                periods,
                                func(period) {
                                    //if the period is the same as the one we are updating
                                    if (period.start == p.start and period.end == p.end) {
                                        updatedPeriod;
                                    } else {
                                        //return the original period
                                        period;
                                    };
                                },
                            );

                            //update the user with the new period
                            let updatedUser: User = { periods = updatedPeriods };
                            //update the user in the trie
                            users := Trie.put(users, key userId, Principal.equal, updatedUser).0;
                            return true;
                        };
                    };
                };
            };

        };
        return false;
    };

};
