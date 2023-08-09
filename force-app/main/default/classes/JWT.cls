public class JWT {
    
    public String alg {get;set;}
    public String iss {get;set;}
    public String sub {get;set;}
    public String aud {get;set;}
    public String exp {get;set;}
    public String iat {get;set;}
    public String scope{get; set;}
    public Map<String,String> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
    public String privateKey {get;set;}
    
    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';
    
    public JWT(String alg) {
        this.alg = alg;
        this.validFor = 4000;
    }
    
    public String assertion() {
        
        String jwt = '';
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
         header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        
        system.debug('header'+header.getAsString());
        
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
        system.debug('header --> '+encodedHeader);
        
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('sub', this.sub);
        body.writeStringField('aud', this.aud);
         Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);// //rightNow
        body.writeNumberField('exp', rightNow + 4000);//  //(rightNow + validFor)
        body.writeStringField('scope', this.scope);
       
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();
        
        system.debug('body'+body.getAsString());
        
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
         system.debug('body --> '+base64URLencode(Blob.valueOf(body.getAsString())));
        
        if ( this.alg == HS256 ) {
            Blob key = EncodingUtil.base64Decode(privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);  
        } else if ( this.alg == RS256 ) {
            Blob signature = null;
            
            if (cert != null ) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                
                system.debug('privateKey '+privateKey);
                signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
                 system.debug('privateKey--> '+signature);
                
            }
            jwt += '.' + base64URLencode(signature);  
             system.debug('privateKey--> '+base64URLencode(signature));
        } else if ( this.alg == NONE ) {
            jwt += '.';
        }
        system.debug('jwt--> '+jwt);
        return jwt;
    }
    
    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input); 
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
}