<h1>Sawang-LogTools v1.0</h1>
<p><strong>Sawang-LogTools Suite</strong> adalah kumpulan alat bantu berbasis Bash CLI yang dirancang khusus untuk mempermudah investigasi server, monitoring port, dan pelacakan transaksi log secara cerdas, cepat, dan efisien.</p>
<ul>
<li><strong>Official Website:</strong> <a title="sawang.my.id" href="https://sawang.my.id" target="_blank">https://sawang.my.id</a></li>
<li><strong>Version:</strong> v1.0 (Official Release)</li>
</ul>
<hr />
<h2>🚀 Fitur Utama</h2>
<ul>
<li><strong><code>cekspek</code></strong>: Menampilkan ringkasan cepat spesifikasi hardware server (OS, CPU, RAM, &amp; Storage).</li>
<li><strong><code>cekport</code></strong>: Memeriksa status port jaringan sekaligus mengidentifikasi Process ID (PID) serta nama aplikasi pemilik port tersebut.</li>
<li><strong><code>cekidpel</code></strong>: <em>Log Locator</em> pintar untuk melacak baris transaksi ID Pelanggan/Biller. Mendukung pencarian multi-folder, filter tanggal, dan <strong>Mode Locator</strong> (hanya menampilkan path file tanpa duplikat).</li>
</ul>
<hr />
<h2>🛠️ Cara Instalasi di Server Target</h2>
<p>Untuk memasang <em>toolset</em> ini di server Anda, cukup jalankan perintah otomatis satu baris ini di terminal:</p>
<pre><code>curl -sSO https://raw.githubusercontent.com/sawangmyid/sawang-logtools/main/install.sh &amp;&amp; bash install.sh</code></pre>
<p>Setelah instalasi selesai, muat ulang konfigurasi terminal Anda agar perintah dapat langsung dikenali:</p>
<pre><code>source ~/.bashrc</code></pre>

<h2>🛠️ Cara reinstall/update di Server Target</h2>
<pre><code>rm -f install.sh && curl -sSO https://raw.githubusercontent.com/sawangmyid/sawang-logtools/main/install.sh && bash install.sh</code></pre>

<h3>🔒 Keamanan &amp; Cadangan (Backup)</h3>
<p>Installer otomatis akan menyimpan salinan aman <code>.bashrc</code> asli Anda di dalam direktori:<br /> <code>~/logtools/backup_config/.bashrc.bak.[TANGGAL_JAM]</code></p>
<hr />
<h2>📖 Contoh Penggunaan Perintah</h2>
<p>Semua perangkat di dalam <em>suite</em> ini mendukung pengecekan versi menggunakan flag <code>-v</code> atau <code>version</code>.</p>
<pre><code>cekidpel -v</code></pre>
<h3>1. Perintah: <code>cekspek</code></h3>
<pre><code>cekspek</code></pre>
<h3>2. Perintah: <code>cekport</code></h3>
<pre><code>cekport 8080</code></pre>
<h3>3. Perintah: <code>cekidpel</code></h3>
<ul>
<li><strong>Cari Semua Riwayat:</strong>
<pre><code>cekidpel 23444</code></pre>
</li>
<li><strong>Filter Tanggal &amp; Kunci Folder Aplikasi:</strong>
<pre><code>cekidpel 23444 2026-06-24 /opt/switcher</code></pre>
</li>
<li><strong>Mode Locator (Hanya Tampilkan Path File):</strong>
<pre><code>cekidpel 23444 path /opt/switcher</code></pre>
</li>
</ul>
<hr />
<h3>📝 Lisensi &amp; Hak Cipta</h3>
<p>Hak Cipta © 2026 <a title="Sawang" href="https://sawang.my.id" target="_blank">Sawang</a>. Seluruh kode di dalam repositori ini dirilis untuk optimalisasi performa server produksi.</p>
