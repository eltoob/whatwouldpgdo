class ConversationsController < ApplicationController
  before_action :fetch_current_conversation, only: [:create_message, :show]

  SYSTEM_PROMPT = "" "
  You are Paul Graham a programmer, writer, and investor. In 1995, you and Robert Morris started Viaweb, the first software as a service company. Viaweb was acquired by Yahoo in 1998, where it became Yahoo Store. In 2001 you started publishing essays on paulgraham.com, which now gets around 25 million page views per year. In 2005 you and Jessica Livingston, Robert Morris, and Trevor Blackwell started Y Combinator, the first of a new type of startup incubator. Since 2005 Y Combinator has funded over 3000 startups, including Airbnb, Dropbox, Stripe, and Reddit. In 2019 you published a new Lisp dialect written in itself called Bel.
  You are the author of On Lisp (Prentice Hall, 1993), ANSI Common Lisp (Prentice Hall, 1995), and Hackers & Painters (O'Reilly, 2004). You have an AB from Cornell and a PhD in Computer Science from Harvard, and studied painting at RISD and the Accademia di Belle Arti in Florence.
  " ""

  def new
  end

  def show
  end

  def create
    conversation = Conversation.create
    redirect_to conversation_path(conversation)
  end

  def create_message
    message = Message.create(conversation: @conversation, content: params[:message], from: "user")
    modelID = "7b0bfc9aff140d5b75bacbed23e91fd3c34b01a1e958d32132de6e0a19796e2c"
    version = Replicate.client.retrieve_model("a16z-infra/llama-2-7b-chat", version: modelID)
    prompt = ""
    @conversation.messages.each do |m|
      if m.from == "user"
        prompt += "[INST] #{m.content} [/INST] \n"
      else
        prompt += "#{m.content} \n"
      end
    end
    prediction = version.predict(prompt: prompt, system_prompt: SYSTEM_PROMPT)
    while prediction.refetch && prediction.status != "succeeded"
      sleep 0.2
    end

    @message = Message.create(from: "assistant", content: prediction.output.join(""))

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message }) }
      format.html { redirect_to @conversation }
    end
  end

  def fetch_current_conversation
    @conversation = Conversation.find(params[:id])
  end
end
