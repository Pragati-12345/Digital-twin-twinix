from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer

# Initialize chatbot
digitalTwinBot = ChatBot('DigitalTwinBot', storage_adapter='chatterbot.storage.SQLStorageAdapter', database_uri='sqlite:///digitalTwinBot.db')
trainer = ChatterBotCorpusTrainer(digitalTwinBot)
trainer.train("chatterbot.corpus.english")

def get_response(query):
    return str(digitalTwinBot.get_response(query))