package coconut.android;



class Util {
    public static function hash(s:String) {
		var i, l = s.length - 3, t0 = 0, v0 = 0x9dc5, t1 = 0, v1 = 0x811c;
		i = 0;
		while (i < l) {
			v0 ^= s.charCodeAt(i++);
			t0 = v0 * 403;
			t1 = v1 * 403;
			t1 += v0 << 8;
			v1 = (t1 + (t0 >>> 16)) & 65535;
			v0 = t0 & 65535;
			v0 ^= s.charCodeAt(i++);
			t0 = v0 * 403;
			t1 = v1 * 403;
			t1 += v0 << 8;
			v1 = (t1 + (t0 >>> 16)) & 65535;
			v0 = t0 & 65535;
			v0 ^= s.charCodeAt(i++);
			t0 = v0 * 403;
			t1 = v1 * 403;
			t1 += v0 << 8;
			v1 = (t1 + (t0 >>> 16)) & 65535;
			v0 = t0 & 65535;
			v0 ^= s.charCodeAt(i++);
			t0 = v0 * 403;
			t1 = v1 * 403;
			t1 += v0 << 8;
			v1 = (t1 + (t0 >>> 16)) & 65535;
			v0 = t0 & 65535;
		}

		while (i < l + 3) {
			v0 ^= s.charCodeAt(i++);
			t0 = v0 * 403;
			t1 = v1 * 403;
			t1 += v0 << 8;
			v1 = (t1 + (t0 >>> 16)) & 65535;
			v0 = t0 & 65535;
		}

		return ((v1 << 16) >>> 0) + v0;
	}
}