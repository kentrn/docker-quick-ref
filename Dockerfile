#+-------------------------------------------------------------------------------------------------------------------------+
#|                                                                                                                         |
#|                                              Docker Quick Reference Guide                                               |
#|                                                        ver: 1.0                                                         |
#+-------------------------------------------------------------------------------------------------------------------------+
# --------------------------------------------------------------------------------------------------------------------------
# Dockerfile quick reference guide. Contains all instruction + argument expressions available for usage when composing a 
# Dockerfile for Docker v18.06.1-CE
# --------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------
# <VAR> represents an ARGUMENT provided by you
# (<VAR>) represents an OPTIONAL ARGUMENT
# ${VAR} or $VAR represents a CALL TO AN ENVIRONMENT VARIABLE defined in ENV
#
# FORMS:
# <INSTRUCTION> <CMD> ... is a SHELL form of instruction. It calls "/bin/sh -c" internally and processes the instruction
# before outputting.
# <INSTRUCTION> ["<CMD>","<PARAM_1>",...] is an EXEC form of instruction. It calls the executable directly. 
# --------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------
# INSTRUCTION SET FOR VARIABLES
# --------------------------------------------------------------------------------------------------------------------------

ARG <KEY>(=<DEFAULT_VALUE>)
# USE WHEN: PASSING IN VARIABLES THAT WILL BE AVAILABLE DURING BUILD TIME OF THE CONTAINER ONLY
# EXAMPLE: ARG VERSION=latest
# NOTE: ARG DEFINITIONS COME INTO EFFECT FROM THE LINE IN WHICH IT IS DECLARED
 
ENV <KEY> <VALUE>
ENV <KEY_1>=<VALUE_1> <KEY_2>=<VALUE_2> ...
# USE WHEN: PASSING IN ENVIRONMENT VARIABLES THAT WILL BE AVAILABLE DURING BUILD AND RUN TIME OF THE CONTAINER
# EXAMPLE: ENV welcome_text hello world!
# EXAMPLE: ENV welcole_text=hello\ world! env=prod secret=abc123
# NOTE: ENV VARS ARE AVAILABLE FOR ALL SUBSEQUENT INSTRUCTIONS IN THE BUILD STAGE

LABEL <KEY_1>=<VALUE_1> <KEY_2>=<VALUE_2> ...
# USE WHEN: ADDING CUSTOM METADATA/TAGS TO YOUR CONTAINER THAT CAN BE RETRIEVED VIA DOCKER INSPECT OR EXTERNAL CMDS
# EXAMPLE: LABEL env=prod service_key=abc123 secret=abc123

# --------------------------------------------------------------------------------------------------------------------------
# INSTRUCTION SET FOR BUILD CONFIGURATION
# --------------------------------------------------------------------------------------------------------------------------

FROM <IMAGE>(:<TAG>) (AS <STAGE_NAME>)
FROM <IMAGE>[@<DIGEST>] (AS <STAGE_NAME>)
# EXAMPLE: FROM centos:latest AS builder

USER <USER>(:<GROUP>)
# EXAMPLE: USER username:usergroup
# NOTE: IF USER DOES NOT HAVE A PRIMARY GROUP THEN THE IMAGE WILL BE RUN WITH THE ROOT GROUP

EXPOSE <PORT>(/<PROTOCOL>) ...
# EXAMPLE: EXPOSE 80/tcp
# EXAMPLE: EXPOSE 80/tcp 80/udp 443/tcp

HEALTHCHECK [--interval=DURATION --timeout=DURATION  --start-period=DURATION --retries=N] <CMD> <COMMAND>
# EXAMPLE: HEALTHCHECK --interval=5m --timeout=3s \
#          CMD curl -f http://localhost/ || exit 1
# NOTE: THERE CAN ONLY BE ONLY ONE HEALTHCHECK INSTRUCTION IN A DOCKER FILE

# --------------------------------------------------------------------------------------------------------------------------
# INSTRUCTION SET FOR RUNNING COMMANDS/EXECUTABLES
# --------------------------------------------------------------------------------------------------------------------------

ENTRYPOINT <COMMAND> <PARAM_1> <PARAM_2> ...
ENTRYPOINT ["<EXECUTABLE>","<PARAM_1>","<PARAM_2>", ...]
# USE WHEN: CONFIGURING A CONTAINER TO RUN AS AN EXECUTABLE
# EXAMPLE: ENTRYPOINT ["/bin/echo","Hello world"]
# NOTE: ENTRYPOINT IS ALWAYS RUN AND NOT IGNORED WHEN DOCKER IS RUN WITH CMD LINE PARAMS
#NOTE: SHELL FORM OF ENTRYPOINT IGNORES ANY CMD OR DOCKER RUN CMD LINE PARAMS

RUN <COMMAND>
RUN ["<EXECUTABLE>","<PARAM_1>","<PARAM_2>", ...]
# USE WHEN: INSTALLING PACKAGES
# EXAMPLE: RUN /bin/bash **SHELL FORM**
# EXAMPLE: RUN ["/bin/bash", "-c", "echo hello"] **EXEC FORM**

CMD <COMMAND_1> <PARAM_1> <PARAM_2> ...
CMD ["<EXECUTABLE>", "<PARAM_1>","<PARAM_2>", ...]
CMD ["<PARAM_1>","<PARAM_2>", ...]
# USE WHEN: DECLARING A DEFAULT COMMAND TO RUN WHEN NONE IS SPECIFIFED IN DOCKER BUILD PARAMS
# EXAMPLE: CMD echo "Hello World!" | wc - **SHELL FORM**
# EXAMPLE: CMD ["echo", "Hello World!"] **EXEC FORM**
# NOTE: THERE CAN ONLY BE ONE INSTANCE OF CMD.
# NOTE: MAIN PURPOSE OF CMD IS TO PROVIDE DEFAULTS FOR EXECUTING A CONTAINER AND WILL BE OVERWRITTEN BY CMDS DECLARED IN
#       DOCKER BUILD

SHELL ["<EXECUTABLE>","<PARAM_1>","<PARAM_2>",...]
# USE WHEN: OVERRIDING THE DEFAULT SHELL COMMAND
# EXAMPLE: SHELL ["/bin/bash", "-c", "echo Running bash!"]
#          RUN echo hello
# NOTE: EACH SHELL INSTRUCTION OVERWRITES ALL PREVIOUS SHELL INSTRUCTIONS AND AFFECTS ALL SUBSEQUENT SHELL INSTRUCTIONS

# --------------------------------------------------------------------------------------------------------------------------
# INSTRUCTION SETS FOR FILES
# --------------------------------------------------------------------------------------------------------------------------

ADD (--chown=<USER>(:<GROUP>)) <SRC> ... <DEST>
ADD (--chown=<USER>(:<GROUP>)) ["<SRC_1>","<SRC_2>",...,"<DEST>"] 
# EXAMPLE: ADD --chown=55:mygroup testfiles* /absolutedir/ 
# EXAMPLE: ADD --chown=55:mygroup http://example.com/foobar /mydir/
# NOTE: THE <SRC> PATH MUST BE INSIDE THE CONTEXT OF THE BUILD.
# NOTE: IF <SRC> IS A URL AND DEST DOES NOT END WITH A TRAILING SLASH THEN FILENAME IS INFERRED FROM URL
# NOTE: IF <SRC> IS A LOCAL TAR ARCHIVE THEN IT IS UNPACKED AS A DIR. REMOTE TARS ARE NOT UNPACKED.  

COPY (--chown=<USER>(:<GROUP>)) <SRC> ../ <DEST>
COPY (--chown=<USER>(:<GROUP>)) ["<SRC_1>","<SRC_2>",...,"<DEST>"]
# EXAMPLE: COPY --chown=55:mygroup testfiles* /absolutedir/ 
# EXAMPLE: COPY --chown=55:mygroup http://example.com/foobar /mydir/
# NOTE: THE <SRC> PATH MUST BE INSIDE THE CONTEXT OF THE BUILD.
# NOTE: IF <SRC> IS A DIRECTORY THEN THE ENTIRE CONTENTS OF THE DIRECTORY ARE COPIED, NOT THE DIRECTORY ITSELF

VOLUME <PATH_1> <PATH_2> ...
VOLUME ["<PATH_1>","<PATH_2>", ...]
# EXAMPLE: VOLUME /myexternalvol

WORKDIR <PATH>
# EXAMPLE: WORKDIR /A
#          WORKDIR B
# ACTIVE PATH WILL BE /A/B
# NOTE: WORKDIR CAN BE USED MULTIPLE TIMES. IF REL PATH IS PROVIDED, IT WILL BE PROVIDED RELATIVE TO PREVIOUS INSTRUCTION

# --------------------------------------------------------------------------------------------------------------------------
# MISC INSTRUCTIONS
# --------------------------------------------------------------------------------------------------------------------------

STOPSIGNAL <SIGNAL>
# EXAMPLE: STOPSIGNAL <SIGNAL>

ONBUILD [<INSTRUCTION>]
# USE WHEN: TRIGGERING INSTRUCTIONS IN THE CALLING BUILD WHEN IT IS USED AS THE BASE IMAGE FOR ANOTHER BUILD
# EXAMPLE: ONBUILD ADD ./app/src