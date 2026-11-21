"use strict";

var count = 0;

function updateMessage() {
  count += 1;
  var message = document.getElementById("message");
  message.textContent = "Обновлений: " + count;
}

document.getElementById("refresh").addEventListener("click", updateMessage);
