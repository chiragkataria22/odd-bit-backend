require("dotenv").config();
const OpenAI = require("openai");
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const BASIC_ASSISTANT_NAME = "Basic Assistant";
const BASIC_ASSISTANT_SYSTEM_MESSAGE =
  "You are an AI assistant to help user with their queries.";

module.exports.getBasicAssistant = async () => {
  let assistants = await openai.beta.assistants.list();
  let assistant = assistants.data.find(
    (assistant) => assistant.name == BASIC_ASSISTANT_NAME
  );
  if (!assistant) {
    console.log(`${BASIC_ASSISTANT_NAME} Not found. Creating one now`);
    assistant = await openai.beta.assistants.create({
      name: BASIC_ASSISTANT_NAME,
      instructions: BASIC_ASSISTANT_SYSTEM_MESSAGE,
      model: "gpt-4o",
    });
  }
  return assistant;
};

let threadId = null; // This will store the thread ID

module.exports.getOrCreateThread = async () => {
  if (!threadId) {
    const thread = await openai.beta.threads.create();
    threadId = thread.id;
  }
  return threadId;
};
