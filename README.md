# 🤖 QuantumAI Trading Bot

Automated trading bot for Bitunix - **Exclusively for Underground Trading members**.

## 🖥️ Compatibility

**Works on all Linux distributions:**
- ✅ Ubuntu 18.04, 20.04, 22.04, 24.04 LTS
- ✅ Ubuntu 25.04, 25.10 and all future versions
- ✅ Debian 9, 10, 11, 12 and future versions
- ✅ Any Linux with Docker installed

## ⚠️ Requirements

1. A Bitunix account **affiliated with Underground Trading**
   👉 [Register here](https://www.bitunix.site/register?vipCode=g3gj7090)
2. At least **1 Futures trade** completed on Bitunix
3. A Linux VPS (Ubuntu 22.04+ recommended)

---

## 🚀 Quick Installation
```bash
# 1. Download the bot
git clone https://github.com/CryptoSauceYT/QuantumAI-Bot.git
cd QuantumAI-Bot

# 2. Configure (REQUIRED)
nano config/application.yaml

# 3. Install and launch
chmod +x install.sh
./install.sh
```

---

## ⚙️ Configuration

Edit `config/application.yaml` and replace:

| Field | Where to find it |
|-------|------------------|
| `your-bitunix-uid` | Bitunix → Profile → Account Settings |
| `api-key` | Bitunix → API Management → Create API |
| `api-secret` | Displayed only once when creating the API |

### Example profile
```yaml
profiles:
  solana:
    your-bitunix-uid: 123456789
    leverage: 6
    amount: all          # or a fixed amount: 50
    secu-tp: 2.0
    secu-sl: 1.5
    entry-type: limit
    api-key: abc123...
    api-secret: xyz789...
```

---

## 📋 Useful Commands

Use `docker compose` (modern) or `docker-compose` (legacy) - both work!

| Action | Command |
|--------|---------|
| View logs | `docker compose logs -f` |
| Restart | `docker compose restart` |
| Stop | `docker compose down` |
| Update | `./install.sh` |
| Status | `docker compose ps` |

---

## 🔄 Updating

When a new version is available:
```bash
cd ~/QuantumAI-Bot
./install.sh
```

---

## ❓ FAQ

**Q: The bot won't start**
→ Check your API keys and UID in `config/application.yaml`

**Q: "NOT AFFILIATED WITH UNDERGROUND TRADING"**
→ Register via the affiliate link and complete at least 1 Futures trade

**Q: How to add multiple profiles?**
→ Copy the `solana:` block and rename it (e.g., `bitcoin:`)

---

## 📞 Support

Join the Underground Trading Discord for help.
