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

        // gather LDAP information from user
        
        char ldapHost[80];        
        char ldapUser[40];
        char ldapPass[40];
        char ldapBase[200];
        
        int ldapPort;
        
        printf("LDAP Host: ");
        scanf("%s", &ldapHost);
        
        printf("LDAP Port: ");
        scanf("%d", &ldapPort);
        
        printf("Bind User: ");
        scanf("%s", &ldapUser);
        
        printf("Password: ");
        scanf("%s", &ldapPass);
        
        printf("Base DN: ");
        scanf("%s", &ldapBase);
        
        
        // initialize ldap API
        
        printf("\nConnecting to %s...\n", ldapHost);
        
        struct ldap *ld = ldap_open(ldapHost, ldapPort);
        
        // attempt a simple bind
        
        int bindResult = ldap_simple_bind_s(ld, ldapUser, ldapPass);
        
        // check bind result for error
        
        if(bindResult != LDAP_SUCCESS) {
            
            int ldapResultCode;
            
            ldap_get_option(ld, LDAP_OPT_RESULT_CODE, &ldapResultCode);
            
            if ( &ldapResultCode != NULL && ldapResultCode != '\0' ) {
                
                printf("\nBind Error: %s\n", ldap_err2string(ldapResultCode));
                
                return -1;
                
            }
        
        }
        
        // attempt a search
        
        printf("\nSearching Directory \"%s\" from %s...\n\n", ldapHost, ldapBase);
        
        LDAPMessage *searchResult;
        
        ldap_search_ext_s(ld, ldapBase, LDAP_SCOPE_SUBTREE, "(objectclass=user)", NULL, 0, NULL, NULL, NULL, 20, &searchResult);
                
        // check search result for error
        
        if(searchResult != LDAP_SUCCESS) {
            
            int ldapResultCode;
            
            ldap_get_option(ld, LDAP_OPT_RESULT_CODE, &ldapResultCode);
            
            if ( &ldapResultCode != NULL && ldapResultCode != '\0' ) {
                
                printf("\nSearch Error: %s\n", ldap_err2string(ldapResultCode));
                
                return -1;
                
            }
            
        }
        
        // loop through all returned entries
        
        LDAPMessage *searchEntries;
        
        for(searchEntries = ldap_first_entry(ld, searchResult); searchResult != NULL; searchResult = ldap_next_entry(ld, searchResult)) {
            
            char *a;
            char **vals;
            int i;
            
            BerElement *ber;
            
            // loop through all of the current entry's attributes
            
            for ( a = ldap_first_attribute( ld, searchResult, &ber );
                 
                a != NULL; a = ldap_next_attribute( ld, searchResult, ber ) ) {
                
                if (( vals = ldap_get_values( ld, searchResult, a )) != NULL ) {
                    
                    for ( i = 0; vals[ i ] != NULL; i++ ) {
                        
                        printf( "%s: %s\n", a, vals[i] );
                        
                    }
                    
                    ldap_value_free(vals);
                    
                }
                
                ldap_memfree( a );
            
            }
            
            if ( ber != NULL ) {
                
                ber_free( ber, 0 );
                
            }
        
        }
        
    ldap_unbind( ld );

    return 0;

    }
    
}


