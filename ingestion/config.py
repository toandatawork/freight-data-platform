import os
from dataclasses import dataclass
from dotenv import load_dotenv

load_dotenv()

# Auto-generates boilerplate (__init__, __repr__) and enforces immutability (read-only object)
@dataclass(frozen=True)
class GhostConfig:
    host: str
    port: int
    database: str
    user: str
    password: str
    sslmode: str

    # Transforms a method into a read-only computed property (called as config.dsn without parentheses)
    @property
    def dsn(self) -> str:
        return (
            f"host={self.host} port={self.port} dbname={self.database} "
            f"user={self.user} password={self.password} sslmode={self.sslmode}"
        )


def load_ghost_config() -> GhostConfig:
    missing = [
        k for k in ("GHOST_HOST", "GHOST_USER", "GHOST_PASSWORD")
        if not os.environ.get(k)
    ]
    if missing:
        raise RuntimeError(
            f"Missing required env vars: {', '.join(missing)}. Copy .env.example to .env and fill it in."
        )
    return GhostConfig(
        host=os.environ["GHOST_HOST"],
        port=int(os.environ.get("GHOST_PORT", 5432)),
        database=os.environ.get("GHOST_DATABASE", "tsdb"),
        user=os.environ["GHOST_USER"],
        password=os.environ["GHOST_PASSWORD"],
        sslmode=os.environ.get("GHOST_SSLMODE", "require"),
    )