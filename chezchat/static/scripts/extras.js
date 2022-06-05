localStorage.clear();

function ajaxCalls(params, element, callback) {
  var xhttp = new XMLHttpRequest();
  xhttp.open("POST", params.url, true);
  xhttp.setRequestHeader("Content-Type", "application/json");

  xhttp.onreadystatechange = function () {
    if (this.readyState === 4 && this.status === 200) {
      var response = JSON.parse(this.responseText);
      if (callback != null) {
        callback(response, element);
      }
    }
  };
  var data = JSON.stringify({ [params.key]: params.payload });
  xhttp.send(data);
}

function addUser(element) {
  var userUsername = element.value;
  var params = { url: "/add-user", payload: userUsername, key: "user_username" };
  ajaxCalls(params, element, processAddUser);
}

function processAddUser(data, element) {
  var userName = element.name;
  var userUsername = element.value;

  var div = createElement("div", {
    id: data["roomID"],
    class: "user-list",
    onclick: "getCurrentRoom(this); verify_status()",
  });

  var divWrap = createElement("div", { class: "noWrapDisplay" });

  var div2 = createElement("div", { class: "name-section" });

  var nameSpan = createElement("span", { class: "name-header" });
  nameSpan.innerHTML = userName;

  var timeSpan = createElement("span", { class: "time-info" });

  appendChildren(div2, [nameSpan, timeSpan]);

  var div3 = createElement("div", { class: "roomDivInfo" });
  var lastMessageSpan = createElement("span", { class: "lastMessage msg" });
  var lastMessageTypingSpan = createElement("span", { class: "lastMessage typing", hidden: true });
  var badgeCounterSpan = createElement("span", { class: "badgeCounter" });

  appendChildren(div3, [lastMessageSpan, lastMessageTypingSpan, badgeCounterSpan]);

  appendChildren(divWrap, [div2, div3]);

  var button = createElement("button", {
    class: "btn btn-danger btn-sm",
    onclick: "toModal(this);",
    name: userName,
    value: userUsername,
  });

  var buttonIcon = createElement("i", { class: "fas fa-user-minus", "aria-hidden": "true" });
  appendChildren(button, [buttonIcon]);

  appendChildren(div, [divWrap, button]);
  document.getElementById("chattables").append(div);

  element.parentNode.remove();
}

function removeUser(element) {
  var roomID = element.parentNode.id;

  var params = { url: "/remove-user", payload: roomID, key: "room_id" };
  ajaxCalls(params, element, processRemoveUser);

  window.event.stopPropagation();
}

function processRemoveUser(data, element) {
  var friendName = element.name;
  var friendUsername = element.value;

  // only so if the current user is currently on the user to remove page
  if (element.value === getUser.innerHTML) {
    resetChatArea(false, false, true, true);
  }

  var div = createElement("div", { class: "user-list" });

  var divWrap = createElement("div", { class: "noWrapDisplay" });

  var div2 = createElement("div", { class: "name-section" });

  var nameSpan = createElement("span", { class: "name-header" });
  nameSpan.innerHTML = friendName;

  appendChildren(div2, [nameSpan]);

  appendChildren(divWrap, [div2]);

  var button = createElement("button", {
    class: "btn btn-success btn-sm",
    onclick: "addUser(this);",
    name: friendName,
    value: friendUsername,
  });

  var buttonIcon = createElement("i", { class: "fas fa-user-plus", "aria-hidden": "true" });
  appendChildren(button, [buttonIcon]);

  appendChildren(div, [divWrap, button]);

  document.getElementById("availableUsers").append(div);

  /* here because this function is also used to append new users whose elements
    are not previously on DOM only to be now appended. Hence they don't exist prior
    so no parentNode to remove */
  if (element.parentNode) {
    element.parentNode.remove();
  }
}

function joinRoom(element) {
  var roomID = element.value;

  var params = { url: "/join-room", payload: roomID, key: "room_id" };
  ajaxCalls(params, element, processJoinRoom);
}

function processJoinRoom(data, element) {
  var roomID = element.value;
  var roomName = element.name;

  var div = createElement("div", {
    class: "user-list",
    onclick: "getCurrentRoom(this)",
    id: roomID,
  });

  var divWrap = createElement("div", { class: "noWrapDisplay" });

  var div2 = createElement("div", { class: "name-section" });

  var nameSpan = createElement("span", { class: "name-header" });
  nameSpan.innerHTML = roomName;

  var groupMarkerSpan = createElement("span", { class: "group-marker" });
  groupMarkerSpan.innerHTML = "group";
  
  var timeSpan = createElement("span", { class: "time-info" });
  var lastMessageSpan = createElement("span", { class: "lastMessage msg" });

  if (Object.keys(data.room_last_message).length !== 0) {
    lastMessageSpan.innerHTML = `${data.room_last_message.author}: ${data.room_last_message.messages}`;
    timeSpan.innerHTML = checkDate(data.room_last_message.timestamp);
  }

  appendChildren(div2, [nameSpan, groupMarkerSpan, timeSpan]);

  var div3 = createElement("div", { class: "roomDivInfo" });

  var lastMessageTypingSpan = createElement("span", { class: "lastMessage typing group", hidden: true });

  var badgeCounterSpan = createElement("span", { class: "badgeCounter" });

  appendChildren(div3, [lastMessageSpan, lastMessageTypingSpan, badgeCounterSpan]);

  appendChildren(divWrap, [div2, div3]);

  var button = createElement("button", {
    class: "btn btn-danger btn-sm roomView",
    onclick: "leaveRoom(this);",
    name: roomName,
    value: roomID,
  });

  var spanText = createElement("span", { class: "font-weight-bold" });
  spanText.innerHTML = "Exit";

  appendChildren(button, [spanText]);

  appendChildren(div, [divWrap, button]);

  document.getElementById("chattables").append(div);

  element.parentNode.remove();
}

function leaveRoom(element) {
  var roomID = element.value;
  var roomName = element.name;

  var params = { url: "/leave-room", payload: roomID, key: "room_id" };
  ajaxCalls(params, element, processLeaveRoom);

  window.event.stopPropagation();
}

function resetChatArea(val1, val2, val3, val4) {
  userStatusInfo.innerHTML = "";
  currentRoomName.innerHTML = "";
  getUser.innerHTML = "";
  document.getElementById("pre-user-select").hidden = val1;
  document.getElementById("pre-user-msg").hidden = val2;
  document.getElementById("pre-user-spinner").hidden = val3;
  localStorage.removeItem("current_room_id");
  clearInputResources(val4);
}

function processLeaveRoom(data, element) {
  var roomID = element.value;
  var roomName = element.name;

  if (roomID === localStorage.getItem("current_room_id")) {
    resetChatArea(false, false, true, true);
  }

  var div = createElement("div", { class: "user-list" });

  var divWrap = createElement("div", { class: "noWrapDisplay" });

  var div2 = createElement("div", { class: "name-section" });

  var nameSpan = createElement("span", { class: "name-header" });
  nameSpan.innerHTML = roomName;

  var groupMarkerSpan = createElement("span", { class: "group-marker" });
  groupMarkerSpan.innerHTML = "group";

  appendChildren(div2, [nameSpan, groupMarkerSpan]);

  appendChildren(divWrap, [div2]);

  var button = createElement("button", {
    class: "btn btn-success btn-sm",
    onclick: "joinRoom(this);",
    name: roomName,
    value: roomID,
  });

  var spanText = createElement("span", { class: "font-weight-bold" });
  spanText.innerHTML = "Join";
  appendChildren(button, [spanText]);

  appendChildren(div, [divWrap, button]);

  document.getElementById("availableRooms").append(div);

  if (element.parentNode) {
    element.parentNode.remove();
  }
}

function createElement(element, attributes) {
  var newElement = document.createElement(element);

  for (let key in attributes) {
    newElement.setAttribute(key, attributes[key]);
  }

  return newElement;
}

function appendChildren(parent, children) {
  for (let child in children) {
    parent.appendChild(children[child]);
  }
}
