const API_URL = "http://192.168.1.10:3000/messages";

// جلب الرسائل من الخادم
async function fetchMessages() {
  const response = await fetch(API_URL);
  const messages = await response.json();

  const messagesContainer = document.getElementById("messages-container");
  messagesContainer.innerHTML = "";

  messages.forEach((message) => {
    const messageElement = document.createElement("div");
    messageElement.textContent = `${message.text} (${new Date(message.timestamp).toLocaleString()})`;
    messagesContainer.appendChild(messageElement);
  });
}

// إرسال رسالة إلى الخادم
async function sendMessage() {
  const messageInput = document.getElementById("message-input");
  const messageText = messageInput.value;

  if (!messageText.trim()) {
    alert("Message cannot be empty!");
    return;
  }

  try {
    const response = await fetch(`${API_URL}/send`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text: messageText }),
    });

    if (response.ok) {
      messageInput.value = "";
      fetchMessages();
    } else {
      const error = await response.json();
      alert(error.error);
    }
  } catch (error) {
    alert("Failed to send message");
  }
}

// ربط الأحداث
document.getElementById("send-button").addEventListener("click", sendMessage);

// تحميل الرسائل عند فتح الصفحة
fetchMessages();
