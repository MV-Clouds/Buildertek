global with sharing class PreQual_EmailResponse implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        string myPlainText = email.plainTextBody;
        system.debug('pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp'+email);
        system.debug('pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp'+myPlainText);
        return result;
    }
}