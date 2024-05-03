FROM alpine:latest as builder

RUN apt update -y \
    && apt-get install wget unzip curl -y \
    && wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip \
    && unzip terraform_1.8.2_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

WORKDIR /work/
COPY app/ .

RUN apt-get install python3.9 python3-pip -y \
    && python3 -m pip install -r requirements.txt

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

RUN mkdir aws

FROM alpine:latest

WORKDIR /work

COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform \
    /usr/local/bin/aws /usr/local/bin/aws \
    COPY /work/ /work/

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    AWS_DEFAULT_REGION="us-east-1"

RUN echo "[default]" >> aws/credentials \
    && echo "aws_access_key_id = $(echo $AWS_ACCESS_KEY_ID)" >> aws/credentials \
    && echo "aws_secret_access_key = $(echo $AWS_SECRET_ACCESS_KEY)" >> aws/credentials \
    && apt-get update && apt-get install -y python3.9 python3-pip \
    && python3 -m pip install -r requirements.txt

EXPOSE 8080

CMD ["python3", "app.py"]