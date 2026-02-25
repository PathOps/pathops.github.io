# make chat-zip
CHAT_ZIP=pathops-chat-context.zip

chat-zip:
	@echo "📦 Creating ChatGPT context zip (Markdown only)..."
	@rm -f $(CHAT_ZIP)
	@find docs -type f -name "*.md" -print | zip -@ $(CHAT_ZIP)
	@echo "✅ Created $(CHAT_ZIP)"
	@echo ""
	@echo "Usage:"
	@echo "1) Start a new chat"
	@echo "2) Attach $(CHAT_ZIP)"
	@echo "3) Paste the bootstrap message"

export-chatgpt:
	./scripts/export_repo_for_chatgpt.sh