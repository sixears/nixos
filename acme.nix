{ ... }:

{ # -- acme ssl certificate generation -------------------
  security.acme = { defaults.email = "root@sixears.co.uk";
                    acceptTerms    = true;
                  };
}
