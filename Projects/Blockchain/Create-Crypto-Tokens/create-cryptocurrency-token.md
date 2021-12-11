# Create Cryptocurrency Tokens

Inspiration and Source: YouTube Channel **NetworkChuck**, [you need to create a Cryptocurrency RIGHT NOW!! (Solana token)](https://youtu.be/befUVytFC80)

* Proof of History (PoH)

## Create Solana (SOL) Wallet

Download Solana (SOL):
```
sh -c "$(curl -sSfL https://release.solana.com/v1.8.5/install)"
```

_Note: for a Raspberry Pi you'll have to download the prebuilt binaries._

Create Solana Wallet Address:
```
solana-keygen new
```

_Note: keep your passphrase safe!_

To check your current balance:
```
solana balance
```

## Buy SOL and transfer

Now we need to buy and transfer SOL from your crypto exchange to your Wallet:
* Grab your SOL Wallet Address and use Coinbase to transfer the SOL there.

## Prep Linux

Update your repository:
```
sudo apt update && sudo apt dist-upgrade && sudo apt full-upgrade && sudo apt autoremove -y && sudo apt autoclean && sudo apt clean
```

Install Rust:
```
curl https://sh.rustup.rs -sSf | sh
```

_Note: exit and log back in._

```
sudo apt install libudev-dev
```

```
sudo apt install libssl-dev pkg-config -y
```

```
sudo apt install build-essential -y
```

Use Rust to install Solana's Token program (this might take some time...):
```
cargo install spl-token-cli
```

_Note: This will require at least 4GB RAM on your server/device. More info on the [Token Program Dev Docs](https://spl.solana.com/token)._

## Create Cryptocurrency Token

Create a Token:
```
spl-token create-token
```
_Note: this will use your SOL to create the Token. Copy the token address for later._

Create an account that can hold the Token:
```
spl-token create-account TOKEN_ADDRESS
```

_Note: this will also use some of your SOL. Copy the token account for later._

Fill the Account with Tokens by minting Tokens:
```
spl-token mint TOKEN_ADDRESS SUPPLY_OF_TOKENS TOKEN_ACCOUNT_ADDRESS
```

To view what we just created:
```
spl-token accounts
```

## Transfer Tokens to External Wallets

In order to transfer Tokens out to another Wallet:
* Copy a SOL Wallet Address (i.e. Phantom Wallet) and we need to create an account to transfer SOL to that Wallet if they don't already have an account:
```
spl-token transfer --fund-recipient --allow-unfunded-recipient TOKEN_ADDRESS TOKEN_AMOUNT EXTERNAL_WALLET_ADDRESS
```

To visualize what we just did go to [Solscan](https://solscan.io/) and look for your TOKEN_ADDRESS.

_Note: External SOL Wallet is now being used to do the transfers._

## Token Branding

Create your own Token brand: name + logo (needs to be .png and less than 200 Kilobytes).

