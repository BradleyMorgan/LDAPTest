//
//  main.m
//  LDAPTest
//
//  Created by Bradley Morgan on 6/19/12.
//  Copyright (c) 2012 Morgan Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ldap.h>
#import <lber.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        char *ldapHost;
        int ldapPort;
        char *ldapUser;
        char *ldapPass;
        
        printf("LDAP Host: ");
        scanf("%s", &ldapHost);
        
        // initialize ldap API
        struct ldap *ld = ldap_open("adlb.auburn.edu", 389);
        
        // attempt a simple bind
        int bindResult = ldap_simple_bind(ld, "checkdb01@auburn.edu", "webaccess");
        
        // attempt a search
        
        LDAPMessage *searchResult;
        
        ldap_search_ext_s(ld, "dc=auburn,dc=edu", LDAP_SCOPE_SUBTREE, "(objectclass=user)", NULL, 0, NULL, NULL, NULL, 20, &searchResult);
        
        LDAPMessage *searchEntries;
        
        for(searchEntries = ldap_first_entry(ld, searchResult); searchResult != NULL; searchResult = ldap_next_entry(ld, searchResult)) {
            
            char *a;
            char **vals;
            int i;
            BerElement *ber;
            
            for ( a = ldap_first_attribute( ld, searchResult, &ber );
                 
                 a != NULL; a = ldap_next_attribute( ld, searchResult, ber ) ) {
                
                /* Get and print all values for each attribute. */
                
                if (( vals = ldap_get_values( ld, searchResult, a )) != NULL ) {
                    
                    for ( i = 0; vals[ i ] != NULL; i++ ) {
                        
                        printf( "%s: %s\n", a, vals[ i ] );
                        
                    }
                    
                }
            
            }
        

        }

    return 0;

    }
    
}


