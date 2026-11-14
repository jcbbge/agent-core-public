# Rex configuration

Josh’s Rex and teerex configuration lives in [rexconfig](https://github.com/jcbbge/rexconfig).
Clone it at `~/rexconfig` and follow its README and `./install [--check]`.

The agent messaging commands (`agent-spawn`, `agent-send`, `agent-read`, `seat`) and the rex-context
hook live in rexconfig too (`~/rexconfig/bin`, `~/rexconfig/hooks`), linked on PATH by its install.
The seat's brief and the brief template stay here in `primitives/tools/agent-messaging/`;
`rex/tests` holds only the engine-host guard test. This repository does not install Rex config.
The retired hand-built integration instructions are in git history.
