require_relative "../spec_helper"

describe SSHData::PublicKey::RSA do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key)  { private_key.public_key }
  let(:params)      { public_key.params }

  let(:msg)     { "hello, world!" }
  let(:digest)  { OpenSSL::Digest::SHA1.new }
  let(:raw_sig) { private_key.sign(digest, msg) }
  let(:sig)     { SSHData::Encoding.encode_signature(SSHData::PublicKey::ALGO_RSA, raw_sig) }

  let(:openssh_key) { SSHData::PublicKey.parse(fixture("rsa_leaf_for_rsa_ca.pub")) }

  subject { described_class.new(e: params["e"], n: params["n"]) }

  it "has parameters" do
    expect(subject.e).to eq(params["e"])
    expect(subject.n).to eq(params["n"])
  end

  it "has an openssl representation" do
    expect(subject.openssl).to be_a(OpenSSL::PKey::RSA)
    expect(subject.openssl.to_der).to eq(public_key.to_der)
  end

  it "can verify signatures" do
    expect(subject.verify(msg, sig)).to be(true)
  end

  it "can parse openssh-generate keys" do
    expect { openssh_key.openssl }.not_to raise_error
  end

  it "can verify certificate signatures" do
    SSHData::Certificate.parse(fixture("rsa_leaf_for_rsa_ca-cert.pub"),
      unsafe_no_verify: false
    )
  end
end