/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Mike Vermace
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account();
        // Set some fields on the Account
        acc.Name = 'Mike';
        acc.BillingCity = 'Decorah';
        acc.AccountNumber = '1234';
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc2 = new Account( Name = name, Industry = industry );
        // Insert the Account
        insert acc2;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact cnt = new Contact();
        // Set some fields on the Contact
        String fn = 'Mike';
        String ln = 'Vermace';
        cnt.FirstName = fn;
        cnt.LastName = ln;
        // Set the AccountId field to the given accountId
        cnt.AccountId = accountId;
        // Insert the Contact into the database
        insert cnt;
        // Return the Id of the newly created Contact
        return cnt.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database - must add LastName to the query
        Contact cnt = [SELECT Id, LastName FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        cnt.LastName = newLastName;
        // Update the Contact in the database
        update cnt;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        opp1.StageName = newStage;
        // Update the Opportunity in the database
        update opp1;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        acc.Name = newName;
        acc.Industry = newIndustry;
        // Update the Account with the given Id with the new name and industry
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        List<Opportunity> upsertOpps = new List<Opportunity>();
               
        for (Opportunity opp : opportunities) {
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000 
            opp.StageName = 'Qualification';
            Integer addDays = 90;
            Date today = Date.today();
            opp.CloseDate = today + addDays;
            opp.Amount = 50000;
            upsertOpps.add(opp);
        }
        upsert upsertOpps;
        // Upsert the opportunities List so that records are either updated or created
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
       
        // Create Account sObj instance
        Account newAcct = new Account();
        // Set Name to accountName
        newAcct.Name = accountName;
        upsert newacct; 

        // Declare a List of Opportunities and *.add() to it.  When full, insert the list -> one DML 
        List<Opportunity> insertTheOpp = new List<Opportunity>();     
       
         // Loop through each Opportunity name
        for (String oppName : oppNames) {
            
            Opportunity newOpp = new Opportunity();          
            // Create an Opportunity with the given name
            newOpp.Name = oppName;
            newOpp.AccountId = newAcct.Id;
            newOpp.CloseDate = Date.today().addMonths(3); // I don't like this. Line 147 in test class.  But test passes...hmm. 
            // StageName and CloseDate are required (don't know why Amount is not also required; line 148).  
            // But setting the StageName field arbitrarily is risky I think, because IDK if the picklist is restricted.
            // The next 2 lines work in test but is this safe? 
            String sname = 'Open'; //Open in not in my Org.
            newOpp.StageName = sname; 
            //
            // This seems safer but a lot of work...found this. 
            /*
            List<String> myPicklist = new List<String>();
            Schema.DescribeFieldResult StageName = Opportunity.StageName.getDescribe();
            for (Schema.PicklistEntry f : StageName.getPicklistValues()) {
                myPicklist.add(f.getLabel());
            }
            newOpp.StageName = myPicklist[0];  
            */
            // Add the Opportunity to the list
            insertTheOpp.add(newOpp);    
        }
        insert insertTheOpp;
    }

     
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        // if the Account exists, update the description
        String newAccountDesc;
        // Integer i = accounts.size();
        // i == 0 ? newAccountDesc = 'New Account' : newAccountDesc = 'Updated Account' ; //Why doesn't this work?  
        //accounts.size() > 0 ? newAccountDesc = 'Updated Account' : newAccountDesc = 'New Account' ; //Why doesn't this work? 
        if (accounts.size() > 0 ) {
            newAccountDesc = 'Updated Account';
        } else {
            newAccountDesc = 'New Account';
        }
        // otherwise, create a new Account and set the description
        Account newAccount = new Account();
        newAccount.Name = accountName; //Must include Name as this is required for Insert side.
        newAccount.Description = newAccountDesc; 
       
        // Upsert the Account
        upsert newAccount; 
		return newAccount;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact

		// Extract the Account Name from Contact's LastName

		// Get the account based on the name or create one if it doesn't exist

		// Link the Contact to its Account using the Account Id

		// Upsert the Contacts
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name

        // Insert the Leads

        // Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases

        // Delete the cases
    }
}