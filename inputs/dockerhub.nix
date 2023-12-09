# dockerhub input type when
{
  dockerhub = {
    _ = {
      alpine.latest = "sha256:d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389";
      mariadb.latest = "sha256:15bd5a1891a297e2b1ad33c5fdc40846033e064a152d4cf06841bb19bf8ca46c";
    };
    fireflyiii = {
      core.latest = "sha256:d7c82269538463abf34495650b06a35fccdffc99dbd3fa2f7fb80e2909dc5445";
      data-importer.latest = "sha256:92ae117f4dcf0dd9699f3e4dd589664b16137c7c2c7b30fd24b43f676b8c20f2";
    };
  };
}
