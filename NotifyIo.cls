/*  -*- Mode: Apex -*-
 *  
 *  NotifyIo.cls -- Notify.io API implementation for Apex version 21.0
 *  Software License Agreement (BSD License)
 * 
 *  Copyright (c) 2011 Orangatame LLC.
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 * 
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * This is an implementation of the Notify.io source protocol, enabling you to send
 * notifications to Notify.io users from Apex.
 *
 * See http://www.notify.io/
 *
 * Example:
 * <code>
 * NotifyIo notify = new NotifyIo('<api key>'); // Get an API key at http://www.notify.io/settings
 * notify.email = 'user@host.com';
 * notify.sendNotification('You have a new message', // text
 *                         'New Message',  // title
 *                         'http://www.developerforce.com/assets/developerforcesite/images/icons-single/55X55-Logic.png', // icon
 *                         'https://naX.salesforce.com/pageaddress', // link URL
 *                         null); // tags
 * </code>
 */
public global class NotifyIo {
    public class MissingApiKeyException extends Exception {}
    public class MissingTargetEmailException extends Exception {}
    private String APIKey;
    public String email {get; set;}

    public NotifyIo(String anApiKey) {
        apiKey = anApiKey;
    }


    /**
     * Send a notification to Notify.io
     *
     * @param text The notification text. REQUIRED
     * @param title The title or subject of the notification. OPTIONAL
     * @return The response.
     */
    public HttpResponse sendNotification(String text,
                                         String title) {
        return sendNotification(text, title, null, null, null);
    }

    /**
     * Send a notification to Notify.io
     *
     * @param text The notification text. REQUIRED
     * @param title The title or subject of the notification. OPTIONAL
     * @param iconUrl The URL for an icon to use for the notification. OPTIONAL
     * @return The response.
     */
    public HttpResponse sendNotification(String text,
                                         String title,
                                         String iconUrl) {
        return sendNotification(text, title, iconUrl, null, null);
    }


   /**
    * Send a notification to Notify.io
    *
    * @param text The notification text. REQUIRED
    * @param title The title or subject of the notification. OPTIONAL
    * @param iconUrl The URL for an icon to use for the notification. OPTIONAL
    * @param relatedUrl The URL for a link you want to associate with a notification. OPTIONAL
    * @return The response.
    */
    public HttpResponse sendNotification(String text,
                                         String title,
                                         String iconUrl,
                                         String relatedUrl) {
        return sendNotification(text, title, iconUrl, relatedUrl, null);
    }

   /**
    * Send a notification to Notify.io
    *
    * @param text The notification text. REQUIRED
    * @param title The title or subject of the notification. OPTIONAL
    * @param iconUrl The URL for an icon to use for the notification. OPTIONAL
    * @param relatedUrl The URL for a link you want to associate with a notification. OPTIONAL
    * @param tags Space separated machine-readable classification tags for the notification. OPTIONAL
    * @return The response.
    */
    public HttpResponse sendNotification(String text,
                                         String title,
                                         String iconUrl,
                                         String relatedUrl,
                                         String tags) {
        if (APIKey == null)
            throw new MissingApiKeyException();
        if (email == null)
            throw new MissingTargetEmailException();
        String body = 'text=' + EncodingUtil.urlEncode(text, 'UTF-8');
        body += '&api_key=' + EncodingUtil.urlEncode(APIKey, 'UTF-8');
        if (title != null) {
            body += '&title=' + EncodingUtil.urlEncode(title, 'UTF-8');
        }
        if (iconUrl != null) {
            body += '&icon=' + EncodingUtil.urlEncode(iconUrl, 'UTF-8');
        }
        if (relatedUrl != null) {
            body += '&link=' + EncodingUtil.urlEncode(relatedUrl, 'UTF-8');
        }
        if (tags != null) {
            body += '&tags=' + EncodingUtil.urlEncode(tags, 'UTF-8');
        }
        String emailHash = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(email)));
        String url = 'http://api.notify.io/v1/notify/' + emailHash;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(body);
        Http h = new Http();
        return h.send(req);
    }


}