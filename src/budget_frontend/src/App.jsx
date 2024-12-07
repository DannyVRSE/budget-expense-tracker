import { useEffect, useState } from 'react';
//import { budget_backend } from 'declarations/budget_backend';
import { AuthClient } from "@dfinity/auth-client";

function App() {

  const [identity, setIdentity] = useState(null);

  // One day in nanoseconds
  const days = BigInt(1);
  const hours = BigInt(24);
  const nanoseconds = BigInt(3600000000000);

  const login = async () => {
    //create an auth client
    const authClient = await AuthClient.create();
    //start the login process
    await new Promise((resolve) => {
      authClient.login(
        {
          identityProvider:
            process.env.DFX_NETWORK === "ic"
              ? "https://identity.ic0.app/#authorize"
              : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943#authorize`,
          // Maximum authorization expiration is 8 days
          maxTimeToLive: days * hours * nanoseconds,
          onSuccess: resolve,
        }
      )
    })

    //get the identity
    setIdentity(authClient.getIdentity());

  };

  //logout
  const logout = async () => {
    const authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
      console.log(`Logging out ${identity.getPrincipal().toText()}`);
      await authClient.logout();
    }
    setIdentity(null);
  };

  useEffect(() => {
    //check if the user is already authenticated
    const checkAuthenticated = async () => {
      const authClient = await AuthClient.create();
      if (await authClient.isAuthenticated()) {
        setIdentity(authClient.getIdentity());
      }
    };
    checkAuthenticated();
  }, []);

  return (
    <>
      <h1>IC Budget</h1>
      {!identity && <button onClick={login}>Login</button>}
      {identity && <><p>Logged in as {identity.getPrincipal().toText()}</p>
        <button onClick={logout}>Logout</button></>
      }

    </>
  );
}

export default App;
