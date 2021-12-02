/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toydb`
--

-- --------------------------------------------------------

--
-- Table structure for table `toylist`
--

CREATE TABLE `toylist` (
  `id` int NOT NULL,
  `toy` varchar(256) NOT NULL,
  `receiver` varchar(256) NOT NULL,
  `location` varchar(256) NOT NULL,
  `approved` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `toylist`
--

INSERT INTO `toylist` (`id`, `toy`, `receiver`, `location`, `approved`) VALUES
(1,  'She-Ra, Princess of Power', 'Elaina Love', 'Houston', 1),
(2, 'Bayblade Burst Evolution', 'Jarrett Pace', 'Dallas', 1),
(3, 'Barbie Dreamhouse Playset', 'Kristin Vang', 'Austin', 1),
(4, 'StarWars Action Figures', 'Jaslyn Huerta', 'Amarillo', 1),
(5, 'Hot Wheels: Volkswagen Beach Bomb', 'Eric Cameron', 'San Antonio', 1),
(6, 'Polly Pocket dolls', 'Aracely Monroe', 'El Paso', 1),
(7, 'HTB{f4k3_fl4g_f0r_t3st1ng}', 'HTBer', 'HTBland', 0);
-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'manager', '69bbdcd1f9feab7842f3a1c152062407'),
(2, 'admin', '592c094d5574fb32fe9d4cce27240588');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `toylist`
--
ALTER TABLE `toylist`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `toylist`
--
ALTER TABLE `toylist`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;