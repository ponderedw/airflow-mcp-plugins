import os

from langchain_aws import ChatBedrock as BaseChatBedrock


class ChatBedrock(BaseChatBedrock):
    """A wrapper for the `langchain_aws.ChatBedrock`."""

    def __init__(self, **kwargs):
        """Initialize the `ChatBedrock` with specific configuration."""
        model_type, model_id = os.environ['LLM_MODEL_ID'].split(':', 1)
        default_kwargs = {
            'model_id': model_id,
            'region_name': os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'),
            'max_tokens': int(os.environ.get('LLM_MAX_TOKENS', 8192)),
            'model_kwargs': dict(temperature=0),
        }

        super().__init__(**(default_kwargs | kwargs))
