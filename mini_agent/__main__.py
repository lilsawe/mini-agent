"""Module entrypoint for Mini-Agent."""

import asyncio

from mini_agent.cli import main


if __name__ == "__main__":
    asyncio.run(main())
