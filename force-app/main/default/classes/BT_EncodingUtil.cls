/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_EncodingUtil
* Created by Sagar: 05/09/2017
*
* dBixo Encoding Util

* - Modifications:
* - Sagar, 05/04/2017– Initial Development
************************************************************************** */
public with sharing class BT_EncodingUtil {
    /**************************************************************************
       Purpose: Salasforce urlEncode() replaces " " with "+" that is not working in AWS. It should be replaced by "%20".  
       Parameters: url - URL to encode
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public static String urlEncode(String url){
        String encodedUrl = '';
        if(url != null && url .trim() != ''){
            for(Integer i = 0; i < url.length(); i++){
                // Find the character at specific index
                String character =  String.fromCharArray(new List<integer> { url.charAt(i) } );
                
                if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/'.contains(character)){
                    encodedUrl += character;
                } else if(character == ' '){
                    encodedUrl += '%20';
                } else {
                    encodedUrl += EncodingUtil.urlEncode(character, 'UTF-8');
                }
            }
        }
        return encodedUrl;
    }
}