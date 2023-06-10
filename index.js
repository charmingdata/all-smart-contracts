import Head from "next/head";
import Image from "next/image";
import { Inter } from "next/font/google";
import styles from "@/styles/Home.module.css";
import Web3Modal from "web3modal";
import { providers, Contract } from "ethers";
import { useEffect, useRef, useState } from "react";
import { MY_CONTRACT_ADDRESS, abi } from "../constants";

const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  const [walletConnected, setWalletConnected] = useState(false);

  const [loading, setLoading] = useState(false);
  const [loading2, setLoading2] = useState(false);

  const [sentenceWritten, setSentenceWritten] = useState("So much empty!");
  const [theStoredSen, getTheStoredSen] = useState("");

  const web3ModalRef = useRef();

  const connectWallet = async () => {
    try {
      // Get the provider from web3Modal, which in our case is MetaMask
      // When used for the first time, it prompts the user to connect their wallet
      await getProviderOrSigner();
      setWalletConnected(true);
    } catch (err) {
      console.error(err);
    }
  };

  const getProviderOrSigner = async (needSigner = false) => {
    const provider = await web3ModalRef.current.connect();
    const web3Provider = new providers.Web3Provider(provider);

    // If user is not connected to the Sepolia network, let them know and throw an error
    const { chainId } = await web3Provider.getNetwork();
    if (chainId !== 11155111) {
      window.alert("Change the network to Sepolia");
      throw new Error("Change network to Sepolia");
    }

    if (needSigner) {
      return web3Provider.getSigner();
    }
    return web3Provider;
  };

  useEffect(() => {
    {
      /*Used arrow function syntax for initializeWeb3Modal to avoid re-creating the function on each render.*/
    }

    const initializeWeb3Modal = () => {
      web3ModalRef.current = new Web3Modal({
        network: "sepolia",
        providerOptions: {},
        disableInjectedProvider: false,
      });
    };

    if (!walletConnected) {
      initializeWeb3Modal();
      connectWallet();
    }
  }, [walletConnected]);

  const setTheSentence = async () => {
    try {
      const signer = await getProviderOrSigner(true);
      // Create a new instance of the Contract with a Signer
      const simpleStorageContract = new Contract(
        MY_CONTRACT_ADDRESS,
        abi,
        signer
      );
      // call the setSentence function from the contract
      const tx = await simpleStorageContract.setSentence(sentenceWritten);
      setLoading(true);
      await tx.wait();
      setLoading(false);
    } catch (err) {
      console.error(err);
    }
  };

  const getMySentence = async () => {
    try {
      setLoading2(true);
      const provider = await getProviderOrSigner();
      const simpleStorageContract = new Contract(
        MY_CONTRACT_ADDRESS,
        abi,
        provider
      );
      const _sentenceStored = await simpleStorageContract
        .getSentence()
        .catch((error) => {
          console.error("Revert reason:", error.reason);
        });
      getTheStoredSen(_sentenceStored);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading2(false);
    }
  };

  const renderButton = () => {
    if (walletConnected) {
      if (loading) {
        return <button className={styles.button}>Loading...</button>;
      } else {
        return (
          <button
            onClick={setTheSentence}
            style={{ cursor: "pointer", backgroundColor: "blue" }}
          >
            Submit
          </button>
        );
      }
    } else {
      return (
        <button
          style={{ cursor: "pointer", backgroundColor: "blue" }}
          onClick={connectWallet}
        >
          Connect your wallet
        </button>
      );
    }
  };

  return (
    <div>
      <Head>
        <title>Storage dApp</title>
        <meta name="description" content="Storage-Dapp" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/logo-charmingdata-small.ico" />
      </Head>
      <main className={`${styles.main} ${inter.className}`}>
        <div className={styles.description}>
          <div>
            <a
              href="https://www.youtube.com/@CharmingData/videos"
              target="_blank"
            >
              By{" "}
              <Image
                src="/logocharmingdata.png"
                alt="charmingdata Logo"
                width={25}
                height={25}
                priority
              />{" "}
              Charming Data
            </a>
          </div>
        </div>

        <div>
          <h1 className={styles.title}>Welcome to the Simple Storage dApp!</h1>
          <div className={styles.description}>
            A contract where you can record text on the bockchain for life.
          </div>
          <br></br>
          <div>
            <label>Write Your Sentence: </label>
            <input
              type="text"
              value={sentenceWritten}
              onChange={(e) => setSentenceWritten(e.target.value)}
              style={{ marginRight: ".5rem" }}
            />
            {renderButton()}
          </div>
          <br></br>
          <div>
            <button
              style={{ cursor: "pointer", backgroundColor: "blue" }}
              onClick={getMySentence}
            >
              Get Stored Sentence
            </button>
            {loading2 ? <p>Loading...</p> : <p>{theStoredSen}</p>}
          </div>
        </div>

        <div className={styles.grid}>
          <a
            href="https://www.linkedin.com/in/charmingdata/"
            className={styles.card}
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2>
              LinkedIn <span>-&gt;</span>
            </h2>
            <p>Connect with us to stay on top of the latest blockchain news.</p>
          </a>

          <a
            href="https://github.com/charmingdata"
            className={styles.card}
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2>
              GitHub <span>-&gt;</span>
            </h2>
            <p>
              Follow the repo to get notified of new smart contracts & dApps.
            </p>
          </a>

          <a
            href="https://www.patreon.com/charmingdata"
            className={styles.card}
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2>
              Patreon <span>-&gt;</span>
            </h2>
            <p>Your support keeps Charming Data running.</p>
          </a>

          <a
            href="https://www.youtube.com/@CharmingData/videos"
            className={styles.card}
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2>
              Youtube <span>-&gt;</span>
            </h2>
            <p>Join us to receive notifications of future video tutorials.</p>
          </a>
        </div>
      </main>
    </div>
  );
}
