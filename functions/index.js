const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.orionAgent = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      const messageData = snap.data();
      const chatId = context.params.chatId;

      // Only respond to user messages
      if (messageData.sender === "user") {
        const agentResponse = {
          text: "Thank you for your message. I am the Orion agent. I have received your message.",
          sender: "agent",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        };

        return snap.ref.parent.add(agentResponse);
      }
      return null;
    });
