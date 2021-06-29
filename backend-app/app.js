var express = require("express");
var app = express();
// const cp = require("child_process");
const shell = require("shelljs");

app.use(express.json());

app.use(express.urlencoded());

app.get("/", function (req, res) {
  res.status(200).send("Hello World!");
});

app.post("/createRootCA", function (req, res) {
  console.log("BODY-->", req.body);
  const hostName = req.body.hostName;
  const userName = req.body.userName;
  const password = req.body.password;
  shell.exec(
    "../scripts/rootCa.sh " + hostName + " " + userName + " " + password,
    (code, out, err) => {
      console.log("CODE==>", code);
      console.log("out==>", out);
      console.log("err==>", err);
      if (code != 0) {
        console.log("ON ERROR");
        res.status(500).send(err);
      } else {
        console.log("ON SUCCESS");
        res.status(200).send("Success");
      }
    }
  );
});

var port = process.env.PORT || 3000;

var server = app.listen(port, function () {
  console.log("Express server listening on port " + port);
});
