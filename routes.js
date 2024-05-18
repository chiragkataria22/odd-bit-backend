require("dotenv").config();
const express = require("express");
const router = express.Router();
const assistantUtils = require("./assistants-utils");
const { exec } = require("child_process");
const fs = require("fs");
const OpenAI = require("openai");
const path = require('path');

// OpenAI API setup
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// API endpoint to get AI response
router.post("/getAiResponse", async (req, res) => {
  const userInput = req.body.userInput;

  // Create a ChatGPT thread and message
  const threadId = await assistantUtils.getOrCreateThread();
  await openai.beta.threads.messages.create(threadId, {
    role: "user",
    content: userInput,
  });

  const instructions = await getInstructions();

  // Run the assistant and collect response
  openai.beta.threads.runs
    .createAndStream(threadId, {
      assistant_id: "asst_CEUz7EgqmkDaeElkIuzyZNZZ", // Replace with your actual assistant ID
      instructions: instructions,
    })
    .on("textDelta", (textDelta, snapshot) =>
      process.stdout.write(textDelta.value)
    )
    .on("textDone", async (data) => {
      processingOnDone(data, res);
    })
    .on("error", (error) => {
      res.status(500).json({ success: false, message: error.message });
    });
});

async function getInstructions() {
  const files = [
    'intro.txt',
    'check_keywords.txt',
    'files_operations.txt',
    'k8s_scaling.txt',
    'ec2_instance.txt',
    'jenkins_pipeline.txt',
    'final_notes.txt'
  ];

  let instructions = '';

  for (const file of files) {
    const filePath = path.join(__dirname, 'prompts', file);
    instructions += await fs.promises.readFile(filePath, 'utf-8') + '\n';
  }

  return instructions;
}

async function processingOnDone(data, res) {
  try {
    if (!data.value) {
      res.json({ success: true, response: "No data found" });
      return;
    }

    const parsedString = JSON.parse(data.value);

    if (!parsedString) {
      res.json({ success: true, response: data.value });
      return;
    }

    const scriptMappings = {
      list_of_directories: {
        message: "Sure, here are the list of files available in the directory",
        script: "./scripts/listOfFiles.sh",
        args: [parsedString.directory_name]
      },
      file_sizes_of_directories: {
        message: "Sure, the total size of files present in the directory is:",
        script: "./scripts/fileSize.sh",
        args: [parsedString.directory_name]
      },
      file_delete_directories: {
        message: "The respected files have been deleted",
        script: "./scripts/deleteDirectories.sh",
        args: [parsedString.directory_name, parsedString.number_of_days]
      },
      pod_scaling: {
        message: "This file will be executed to adjust pod scaling",
        script: "./scripts/podScaling.sh",
        args: [
          parsedString.application_name,
          parsedString.namespace_name,
          parsedString.min_pods,
          parsedString.max_pods
        ]
      },
      ec2_instance: {
        message: "Following terraform actions are now being executed to create EC2 instance.",
        script: "./scripts/terraform.sh",
        args: [
          parsedString.aws_region,
          parsedString.instance_type,
          parsedString.instance_count,
          parsedString.volume_size,
          parsedString.resource_type
        ]
      },
      jenkins: {
        message: "Jenkins Pipeline has been created",
        script: "./scripts/jenkins.sh",
        args: [
          parsedString.label_name,
          parsedString.default_branch,
          parsedString.country_code,
          parsedString.language_code,
          parsedString.app_version,
          parsedString.build_command
        ]
      }
    };

    for (const key in scriptMappings) {
      if (parsedString[key]) {
        const { message, script, args } = scriptMappings[key];
        await returnScriptOutput(res, message, script, args, data);
        return;
      }
    }

    // If no matching key is found
    res.json({ success: true, response: data.value });
  } catch (e) {
    res.json({ success: true, response: data.value });
  }
}

async function returnScriptOutput(res, initialStr, filePath, args, data) {
  try {
    const output = await executeSSHScript(filePath, args);
    res.json({ success: true, response: `${initialStr} \n\n\n ${output !== undefined ? output : data.value}` });
  } catch (error) {
    res.json({ success: false, response: "Error executing script" });
  }
}

function executeSSHScript(scriptPath, args) {
  return new Promise((resolve, reject) => {
    const argsString = args.join(" ");
    exec(`${scriptPath} ${argsString}`, (error, stdout = "", stderr) => {
      if (error) {
        reject(error);
      } else if (stderr) {
        reject(stderr);
      } else {
        resolve(stdout);
      }
    });
  });
}

module.exports = router;
