package com.example.video_call_new;
import com.example.video_call_new.io.agora.media.RtcTokenBuilder2;


public class App {

    static String appId = "42766e6d3d2945719a923106cfc0f7c2";
    static String appCertificate = "85640c7555cf44168c5c24a32457fccb";
    static String channelName = "video_sample_1";
    static int uid = 0; // The integer uid, required for an RTC token
    static int expirationTimeInSeconds = 3600; // The time after which the token expires

    public static void main(String[] args) throws Exception {
        RtcTokenBuilder2 tokenBuilder = new RtcTokenBuilder2();
        // Calculate the time expiry timestamp
        int timestamp = (int)(System.currentTimeMillis() / 1000 + expirationTimeInSeconds);

        System.out.println("UID token");
        String result = tokenBuilder.buildTokenWithUid(appId, appCertificate,
                channelName, uid, RtcTokenBuilder2.Role.ROLE_PUBLISHER, timestamp, timestamp);
        System.out.println(result);
    }

    static String generatedToken(String appId,String appCertificate,String channelName, int uid,int expirationTimeInSeconds){
        RtcTokenBuilder2 tokenBuilder = new RtcTokenBuilder2();
        // Calculate the time expiry timestamp
        int timestamp = (int)(System.currentTimeMillis() / 1000 + expirationTimeInSeconds);

        System.out.println("UID token");
        String result = tokenBuilder.buildTokenWithUid(appId, appCertificate,
                channelName, uid, RtcTokenBuilder2.Role.ROLE_PUBLISHER, timestamp, timestamp);
        System.out.println(result);
        return  result;
    }
}
