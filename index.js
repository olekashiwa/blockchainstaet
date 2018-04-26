const crypto = require('crypto');
const secp256k1 = require('secp256k1');

const msg = process.argv[2]; 
const digested = digest(msg);
console.log(`\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n0) Alice's message: 
	message: ${msg}
	message digest: ${digested.toString("hex")}`);

// generate privateKey
let privateKey;

do {
  privateKey = crypto.randomBytes(32); // генерируем 32 рендомных байта
	//console.log('try: ' + privateKey);
} while (!secp256k1.privateKeyVerify(privateKey));
// get the public key in a compressed format

const publicKey = secp256k1.publicKeyCreate(privateKey);
console.log(`\n1) Alice aquired new keypair:
	publicKey: ${publicKey.toString("hex")}
	privateKey: ${privateKey.toString("hex")}`);


/*
 Sign the message
*/
console.log(`\n2) Alice signed her message digest with her privateKey to get its signature:`);
const sigObj = secp256k1.sign(digested, privateKey);
const sig = sigObj.signature;
console.log("	Signature:", sig.toString("hex"));

/*
 Verify
*/
digest_bad = digest('Не наше сообщение');
console.log(`\n3) Bob verifyed by 3 elements ("message digest", "signature", and Alice's "publicKey"):`);
let verified = secp256k1.verify(digest_bad, sig, publicKey);
console.log("	verified:", verified + '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
// => true


function digest(str_in, algoritm = 'sha256') {
	if(str_in){
		return crypto.createHash(algoritm).update(str_in).digest();
	}
	console.log('Сообщение не было передано');
	process.exit(-1);
}
