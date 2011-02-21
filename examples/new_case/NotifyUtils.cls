/*  -*- Mode: Apex -*-
 *  
 *  NotifyUtils.cls -- Example Notify.io utilities for web callouts.
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

/*
 * Tested on API v20.0
 */
global class NotifyUtils {
    static String API_KEY = '<your api key>';
    static String INSTANCE = 'na3';
    
    @future(callout=true)
    global static void notifyCaseOwners(List<Id> recordIds) {
        /* First, find Case owners: */
        List<Case> cases = [select Id, Subject, Owner.Email from Case where Id in :recordIds];
        NotifyIo notify = new NotifyIo(API_KEY);
        String iconUrl = 'http://' + INSTANCE + '.salesforce.com/img/icon/cases32.png';
        String relatedUrl;
        String tags = 'case'; /* These may or may not be visible, depending on your Notify.io outlet. */
        for (Case c : cases) {
            if (c.owner.email == null) {
                /* Case may be assigned to a queue, or not have an Owner yet. Skip it. */
                continue;
            }
            notify.email = c.Owner.Email;
            relatedUrl = 'https://' + INSTANCE + '.salesforce.com/' + c.Id;
            String subject = 'New Case: ' + c.Subject;
            String text = 'You have a new case assigned to you. Click here to open it.';
            notify.sendNotification(text, subject, iconUrl, relatedUrl, tags);
        }
    }
}