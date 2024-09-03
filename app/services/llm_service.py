import logging

import litellm

logger = logging.getLogger(__name__)


async def get_llm_completion(prompt: str) -> str:
    try:
        response = litellm.completion(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0,
        )
        response_content = response.choices[0].message.content
        logger.info(f"LLM completion response: {response_content}")
        return str(response_content) if response_content is not None else ""
    except Exception as e:
        logger.error(f"Error in LLM completion: {e}")
        raise
